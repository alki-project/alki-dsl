require 'forwardable'
require 'alki/support'

module Alki
  module ClassBuilder
    class << self
      def create_constant(name,value = Class.new, parent=nil)
        parent ||= Object
        *ans, ln = name.to_s.split('::')
        ans.each do |a|
          unless parent.const_defined? a
            parent.const_set a, Module.new
          end
          parent = parent.const_get a
        end

        parent.const_set ln, value
      end

      def build(data)
        class_name = data[:constant_name]
        if !class_name && data[:name]
          class_name = Alki::Support.classify(data[:name])
        end

        klass = find_or_create_class(class_name, data)

        build_class data, klass

        if data[:secondary_classes]
          build_secondary_classes data[:secondary_classes], klass
        end

        klass
      end

      private

      def find_or_create_class(class_name, data)
        type = data[:type] || :class
        klass = Alki::Support.constantize class_name, data[:parent_class] if class_name
        must_create_constant = !klass && class_name

        super_class = data[:super_class] ? Alki.load(data[:super_class]) : Object

        if klass
          validate_existing_class(type, class_name, klass, super_class)
        else
          klass = case type
            when :module then Module.new
            when :class then Class.new(super_class)
          end
        end

        if must_create_constant
          create_constant class_name, klass, data[:parent_class]
        end
        klass
      end

      def validate_existing_class(type, class_name, klass, super_class)
        if type == :module
          if klass.class != Module
            raise "#{class_name} already exists as a #{klass.class}"
          end
        elsif type == :class
          if klass.class != Class
            raise "#{class_name} already exists as a #{klass.class}"
          elsif klass.superclass != super_class
            raise "#{class_name} already exists with different super class"
          end
        end
      end

      def build_secondary_classes(secondary_classes, parent_class)
        secondary_classes.each do |data|
          if data[:subclass]
            data = data.merge(parent_class: parent_class,constant_name: data[:subclass])
          elsif !data[:constant_name] && !data[:name]
            raise ArgumentError.new("Secondary classes must have names")
          end
          build data
        end
      end

      def module_not_empty?(mod)
        not mod.instance_methods.empty? &&
          mod.private_instance_methods.empty?
      end

      def build_class(data,klass)
        if data[:module]
          if module_not_empty? data[:module]
            klass.include data[:module]
          end
          if data[:module].const_defined?(:ClassMethods) &&
            module_not_empty?(data[:module]::ClassMethods)
            klass.extend data[:module]::ClassMethods
          end
        end

        if data[:modules]
          data[:modules].each do |mod|
            klass.include Alki.load mod
          end
        end
        if data[:class_modules]
          data[:class_modules].each do |mod|
            klass.extend Alki.load mod
          end
        end

        add_methods klass, data
        add_initialize klass, data[:initialize_params] if data[:initialize_params]
      end

      def add_methods(klass, data)
        if data[:class_methods]
          data[:class_methods].each do |name, method|
            klass.define_singleton_method name, &method[:body]
            klass.singleton_class.send :private, name if method[:private]
          end
        end

        if data[:instance_methods]
          data[:instance_methods].each do |name, method|
            klass.send :define_method, name, &method[:body]
            klass.send :private, name if method[:private]
          end
        end

        if data[:delegators]
          klass.extend Forwardable
          data[:delegators].each do |name,delegator|
            klass.def_delegator delegator[:accessor], delegator[:method], name
          end
        end

        klass.send :attr_reader, *data[:attr_readers] if data[:attr_readers]
        klass.send :attr_writer, *data[:attr_writers] if data[:attr_writers]
        klass.send :attr_accessor, *data[:attr_accessors] if data[:attr_accessors]
      end

      def add_initialize(klass,params)
        at_setters = ''
        params.each do |p|
          p,default = p.is_a?(Array) ? p : [p,nil]
          if default
            default_method = "_default_#{p}".to_sym
            klass.send(:define_method, default_method, &default)
            klass.send :private, default_method
            at_setters << "@#{p} = #{p} || #{default_method}\n"
          else
            at_setters << "@#{p} = #{p}\n"
          end
        end

        klass.class_eval "
        def initialize(#{params.map{|p| p.is_a?(Array) ? "#{p[0]}=nil" : p.to_s}.join(', ')})
        #{at_setters}end"
      end
    end
  end
end

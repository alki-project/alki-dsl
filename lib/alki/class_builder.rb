require 'forwardable'
require 'alki/support'

module Alki
  class ClassBuilder
    def self.create_constant(name,value = Class.new, parent=nil)
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

    def self.build(data)
      class_name = data[:class_name]
      if !class_name && data[:name] && data[:prefix]
        class_name = Alki::Support.classify(
          data[:prefix].empty? ? data[:name] : "#{data[:prefix]}/#{data[:name]}"
        )
      end

      klass = Alki::Support.constantize class_name, data[:parent_class] if class_name
      must_create = !klass

      if data[:type] == :module
        if klass
          if klass.class != Module
            raise "#{class_name} already exists as is a #{klass.class}"
          end
        else
          klass = Module.new
        end
      else
        if klass && klass.class != Class
          raise "#{class_name} already exists as is a #{klass.class}"
        end
        super_class = if data[:super_class]
          Alki::Support.load_class data[:super_class]
        else
          Object
        end
        if klass
          if klass.superclass != super_class
            raise "#{class_name} already exists with different super class"
          end
        else
          klass = Class.new super_class
        end
      end
      build_class data, klass
      if class_name && must_create
        create_constant class_name, klass, data[:parent_class]
      end
      if data[:secondary_classes]
        data[:secondary_classes].each do |data|
          if data[:subclass]
            data = data.merge(parent_class: klass,class_name: data[:subclass])
          elsif !data[:class_name] && !data[:name]
            raise ArgumentError.new("Secondary classes must have names")
          end
          build data
        end
      end
      klass
    end

    def self.module_not_empty?(mod)
      not mod.instance_methods.empty? &&
        mod.private_instance_methods.empty?
    end

    def self.build_class(data,klass)
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
          klass.include mod
        end
      end
      if data[:class_modules]
        data[:class_modules].each do |mod|
          klass.extend mod
        end
      end

      add_methods klass, data
      add_initialize klass, data[:initialize_params] if data[:initialize_params]
    end

    def self.add_methods(klass, data)
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

    def self.add_initialize(klass,params)
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

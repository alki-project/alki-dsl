module Alki
  module Dsl
    module ClassHelpers
      def class_builder(subclass = nil)
        unless @ctx[:class_builder]
          @ctx[:class_builder] = {}
          %i(module name prefix).each do |attr|
            @ctx[:class_builder][attr] = @ctx[attr] if @ctx[attr]
          end
        end
        if subclass
          scs = @ctx[:class_builder][:secondary_classes] ||= []
          cb = scs.find { |sc| sc[:subclass] == subclass }
          unless cb
            cb = { subclass: subclass }
            scs << cb
          end
          cb
        else
          @ctx[:class_builder]
        end
      end

      def create_as_module(subclass: nil)
        class_builder(subclass)[:type] = :module
      end

      def set_super_class(klass,subclass: nil)
        class_builder(subclass)[:super_class] = klass
      end

      def add_method(name,context:nil,private: false,subclass: nil, &blk)
        class_builder(subclass)[:instance_methods] ||= {}
        class_builder(subclass)[:instance_methods][name.to_sym] = {
          body: blk,
          context: context,
          private: private
        }
      end

      def add_class_method (name,context: nil,private: false,subclass: nil,&blk)
        class_builder(subclass)[:class_methods] ||= {}
        class_builder(subclass)[:class_methods][name.to_sym] = {
          body: blk,
          context: context,
          private: private
        }
      end

      def add_helper(name,&blk)
        class_builder('Helpers')[:type] = :module
        add_method name, &blk
        add_method name, subclass: 'Helpers', &blk
      end

      def add_helper_module(mod)
        class_builder('Helpers')[:type] = :module
        add_module mod
        add_module mod, subclass: 'Helpers'
      end

      def add_initialize_param(name,opts={},&default)
        name = name.to_sym
        param = default ? [name,default] : name
        (class_builder(opts[:subclass])[:initialize_params]||=[]) << param
      end

      def add_instance_class_proxy(type, name,subclass: nil)
        (class_builder(subclass)[:instance_class]||={})[name.to_sym] = {type: type}
      end

      def add_module(mod,subclass: nil)
        (class_builder(subclass)[:modules]||=[]) << mod
      end

      def add_accessor(name,type: :accessor,subclass: nil)
        (class_builder(subclass)["attr_#{type}s".to_sym]||=[]) << name
      end

      def add_delegator(name,accessor,method=name,subclass: nil)
        (class_builder(subclass)[:delegators]||={})[name] = {
          accessor: accessor,
          method: method
        }
      end
    end
  end
end

module Alki
  module Dsl
    module ClassHelpers
      def class_builder
        unless @ctx[:class_builder]
          @ctx[:class_builder] = {}
          %i(name prefix).each do |attr|
            @ctx[:class_builder][attr] = @ctx[attr] if @ctx[attr]
          end
        end
        @ctx[:class_builder]
      end

      def create_as_module
        class_builder[:type] = :module
      end

      def set_super_class(klass)
        class_builder[:super_class] = klass
      end

      def add_method(name,private: false, &blk)
        class_builder[:instance_methods] ||= {}
        class_builder[:instance_methods][name.to_sym] = {
          body: blk,
          private: private
        }
      end

      def add_class_method (name,private: false,&blk)
        class_builder[:class_methods] ||= {}
        class_builder[:class_methods][name.to_sym] = {
          body: blk,
          private: private
        }
      end

      def add_initialize_param(name)
        class_builder[:initialize_params] ||= []
        class_builder[:initialize_params] << name.to_sym
      end

      def add_instance_class_proxy(type, name)
        class_builder[:instance_class] ||= {}
        class_builder[:instance_class][name.to_sym] = {type: type}
      end

      def add_module(mod)
        class_builder[:modules] ||= []
        class_builder[:modules] << mod
      end
    end
  end
end
require 'alki/dsl/base'
require 'alki/dsl/class_helpers'
require 'alki/class_builder'

module Alki
  module Dsls
    class Class < Alki::Dsl::Base
      include Alki::Dsl::ClassHelpers

      self::Helpers = Alki::Dsl::ClassHelpers

      def self.dsl_info
        {
          methods: %i(class_methods),
          finish: :finish
        }
      end

      def class_methods(&blk)
        unless ctx[:module].const_defined? :ClassMethods
          ctx[:module].const_set :ClassMethods, Module.new
        end
        ctx[:module]::ClassMethods.class_exec &blk
      end

      def finish
        ctx[:result] = Alki::ClassBuilder.build class_builder
        ctx.delete :class_builder
      end
    end
  end
end

require 'alki/dsl/base'
require 'alki/support'
require 'alki/dsl/class_helpers'

module Alki
  module Dsls
    class Dsl < Alki::Dsl::Base
      include Alki::Dsl::ClassHelpers
      Helpers = Alki::Dsl::ClassHelpers

      def self.dsl_info
        {
          requires: [['alki/dsls/class',:before]],
          methods: [
            :dsl_method,
            [:init,:dsl_init],
            [:finish,:dsl_finish],
            :require_dsl,
            :helper,
            :helper_module
          ],
          init: :init,
          finish: :finish
        }
      end

      def init
        @info = {
          methods: [],
          requires: []
        }
        @helper_modules = []
        @helpers = {}
      end

      def dsl_method(name, &blk)
        method_name = name.to_sym
        add_method method_name, private: true, &blk
        @info[:methods] << [name.to_sym,method_name]
      end

      def dsl_init(&blk)
        add_method :_dsl_init, private: true, &blk
        @info[:init] = :_dsl_init
      end

      def dsl_finish(&blk)
        add_method :_dsl_finish, private: true, &blk
        @info[:finish] = :_dsl_finish
      end

      def require_dsl(dsl, order=:before)
        dsl_class = Alki.load(dsl)
        @info[:requires] << [dsl_class,order]
        if defined? dsl_class::Helpers
          add_module dsl_class::Helpers
          add_helper_module dsl_class::Helpers
        end
      end

      def helper(name,&blk)
        add_helper name, &blk
      end

      def helper_module(mod)
        add_helper_module mod
      end

      def finish
        set_super_class 'alki/dsl/base'
        info = @info.freeze
        add_class_method :dsl_info do
          info
        end
      end
    end
  end
end

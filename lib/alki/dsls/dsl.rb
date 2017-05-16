require 'alki/dsl/base'
require 'alki/support'
require 'alki/dsl/class_helpers'

module Alki
  module Dsls
    class Dsl < Alki::Dsl::Base
      module Helpers
        include Alki::Dsl::ClassHelpers

        def add_helper(name,&blk)
          add_method name, &blk
          add_method name, subclass: 'Helpers', &blk
        end

        def add_helper_module(mod)
          add_module mod
          add_module mod, subclass: 'Helpers'
        end
      end

      include Helpers

      def self.helpers
        [Helpers]
      end

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
        dsl_class = Alki.load dsl
        @info[:requires] << [dsl,order]
        dsl_class.helpers.each do |helper|
          add_module helper
          add_helper_module helper
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
        create_as_module(subclass: 'Helpers')

        add_class_method :helpers do
          [self::Helpers]
        end
        info = @info.freeze
        add_class_method :dsl_info do
          info
        end

        add_method(:require_dsl,private: true) do |dsl,order=:before|
          dsl_class = Alki.load dsl
          dsl_class.helpers.each do |helper|
            self.singleton_class.send :include, helper
          end
          @evaluator.update requires: [[dsl,order]]
        end
      end
    end
  end
end

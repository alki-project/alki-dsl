require 'alki/support'
require 'alki/dsl/builder'

module Alki
  module Dsl
    class Base
      extend Alki::Dsl::Builder

      def self.generate(evaluator,ctx)
        obj = new(ctx,evaluator)
        result = {methods: {}}
        info = self.dsl_info

        result[:init] = obj.method(info[:init]) if info[:init]
        result[:finish] = obj.method(info[:finish]) if info[:finish]
        result[:requires] = info[:requires] if info[:requires]

        if info[:methods]
          info[:methods].each do |method|
            if method.is_a?(Array)
              name, method = method
            else
              name = method
            end
            result[:methods][name] = obj.method method
          end
        end

        if info[:helpers]
          info[:helpers].each do |method|
            if method.is_a?(Array)
              name, method = method
            else
              name = method
            end
            result[:helpers][name] = obj.method method
          end
        end
        evaluator.update result
      end

      def self.dsl_info
        {}
      end

      def self.helpers
        []
      end

      def initialize(ctx,evaluator)
        @ctx = ctx
        @evaluator = evaluator
      end

      attr_reader :ctx
    end
  end
end

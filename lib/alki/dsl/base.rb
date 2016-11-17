require 'alki/support'
require 'alki/dsl/evaluator'

module Alki
  module Dsl
    class Base
      def self.build(data={},&blk)
        Alki::Dsl::Evaluator.evaluate self, data, &blk
      end

      def self.generate(ctx)
        obj = new(ctx)
        result = {methods: {}}
        info = self.dsl_info

        result[:init] = obj.method(info[:init]) if info[:init]
        result[:finish] = obj.method(info[:finish]) if info[:finish]
        result[:requires] = info[:requires] if info[:requires]
        result[:helpers] = info[:helpers] if info[:helpers]

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
        result
      end

      def self.dsl_info
        {}
      end

      def initialize(ctx)
        @ctx = ctx
      end

      attr_reader :ctx
    end
  end
end
require 'alki/support'
require 'alki/dsl/builder'

module Alki
  module Dsl
    class Base
      extend Alki::Dsl::Builder

      def self.generate(ctx)
        obj = new(ctx)
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
        result
      end

      def self.dsl_info
        {}
      end

      def self.helpers
        if defined? self::Helpers
          [self::Helpers]
        else
          []
        end
      end

      def initialize(ctx)
        @ctx = ctx
      end

      attr_reader :ctx
    end
  end
end

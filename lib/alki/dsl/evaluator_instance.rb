module Alki
  module Dsl
    class EvaluatorInstance
      attr_reader :data

      def initialize(evaluator,data,dsl)
        @evaluator = evaluator
        @data = data
        @dsl = dsl
      end

      def require_dsl(dsl)
        @evaluator.require_dsl(self,dsl)
      end
    end
  end
end

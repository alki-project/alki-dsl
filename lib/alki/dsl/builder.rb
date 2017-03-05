require 'alki/dsl/evaluator'

module Alki
  module Dsl
    module Builder
      def build(data={},&blk)
        Alki::Dsl::Evaluator.evaluate self, data, &blk
      end
    end
  end
end

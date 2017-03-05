require 'alki/dsl/builder'

module Alki
  module Dsl
    class Merge
      include Alki::Dsl::Builder

      def initialize(*dsls)
        @dsls = dsls
        @requires = dsls.map{|dsl| [dsl,:before]}.freeze
      end

      def generate(_ctx)
        {
          requires: @requires
        }
      end

      def helpers
        @helpers ||= @dsls.inject([]) do |helpers, dsl|
          helpers.push *Alki.load(dsl).helpers
        end
      end
    end
  end
end

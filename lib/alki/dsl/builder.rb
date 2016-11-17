require 'alki/support'
require 'alki/dsl/evaluator'

module Alki
  module Dsl
    class Builder
      def self.build(data,&blk)
        result = Alki::Dsl::Evaluator.evaluate _dsls,data,&blk
        if _processor
          _processor.build result
        else
          result
        end
      end

      private

      def self.dsl(name)
        klass = Alki::Support.load_class name
        unless klass
          raise "Unable to load class #{name.inspect}"
        end
        dsls = _dsls
        dsls += [klass]
        define_singleton_method(:_dsls) { dsls }
      end

      def self.processor(name)
        klass = Alki::Support.load_class name
        define_singleton_method(:_processor) { klass }
      end

      def self._dsls
        []
      end

      def self._processor
        nil
      end
    end
  end
end
require 'set'
require 'alki/support'
require 'alki/dsl/evaluator_instance'

module Alki
  module Dsl
    class Evaluator
      def self.evaluate(dsl, data={}, &blk)
        evaluator = new(dsl,data)
        evaluator.evaluate &blk
        evaluator.finish
      end

      def initialize(dsl,data)
        @inits = []
        @finishers = []
        @processors = []
        @dsls_seen = Set.new
        @data = data
        @mod = (data[:module] ||= Module.new)
        @dsl = dsl
        evaluator = self
        define_dsl_method :method_missing do |meth,*args,&b|
          evaluator.context.send meth, *args, &b
        end
        process_dsl @dsl
      end

      def build(data={},&blk)
        self.class.evaluate(@dsl,data,&blk)
      end

      def process_dsl(dsl)
        return unless @dsls_seen.add? dsl
        dsl.generate(self,@data)
      end

      def context
        Thread.current[:__alki_dsl_context]
      end

      def evaluate(&blk)
        Thread.current[:__alki_dsl_context] = @data[:context] || blk.binding.receiver
        @mod.class_exec &blk
      end

      def require_dsl(source,dsl)
        dsl_class = Alki.load(dsl)
        dsl_class.new(EvaluatorInstance.new(self,@data))
      end

      def update(cbs)
        after_requires = []
        if cbs[:requires]
          cbs[:requires].each do |(required_dsl,order)|
            case order
              when :before
                process_dsl Alki.load(required_dsl)
              when :after
                after_requires << [Alki.load(required_dsl)]
            end
          end
        end
        cbs[:init].call if cbs[:init]
        @finishers << cbs[:finish] if cbs[:finish]
        if cbs[:methods]
          cbs[:methods].each do |name, proc|
            define_dsl_method name, &proc
          end
        end
        after_requires.each do |process_args|
          process_dsl *process_args
        end
      end

      def define_dsl_method(name,&blk)
        @mod.define_singleton_method name, &blk
      end

      def finish
        @finishers.reverse_each(&:call)
        clear_dsl_methods

        if @data.key? :result
          @data[:result]
        else
          @data
        end
      end

      private

      def clear_dsl_methods
        @mod.singleton_methods do |m|
          @mod.singleton_class.send :remove_method, m
        end
      end
    end
  end
end

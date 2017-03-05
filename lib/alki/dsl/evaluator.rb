require 'set'
require 'alki/support'

module Alki
  module Dsl
    class Evaluator
      def initialize
        @inits = []
        @finishers = []
        @processors = []
        @dsls_seen = Set.new
      end

      def evaluate(dsl,data={},&blk)
        mod = (data[:module] ||= Module.new)
        process_dsl dsl, data

        @inits.each(&:call)
        define_dsl_method mod, :method_missing do |meth,*args,&b|
          blk.binding.receiver.send meth, *args, &b
        end
        dsl_exec mod, &blk
        @finishers.reverse_each(&:call)
        clear_dsl_methods mod

        if data.key? :result
          data[:result]
        else
          data
        end
      end

      def process_dsl(dsl,data)
        return unless @dsls_seen.add? dsl
        cbs = dsl.generate(data)
        after_requires = []
        if cbs[:requires]
          cbs[:requires].each do |(required_dsl,order)|
            case order
              when :before
                process_dsl Alki.load(required_dsl), data
              when :after
                after_requires << [Alki.load(required_dsl), data]
            end
          end
        end
        @inits << cbs[:init] if cbs[:init]
        @finishers << cbs[:finish] if cbs[:finish]
        if cbs[:methods]
          cbs[:methods].each do |name, proc|
            define_dsl_method data[:module], name, &proc
          end
        end
        after_requires.each do |process_args|
          process_dsl *process_args
        end
      end

      def define_dsl_method(mod,name,&blk)
        mod.define_singleton_method name, &blk
      end

      def clear_dsl_methods(mod)
        mod.singleton_methods do |m|
          mod.singleton_class.send :remove_method, m
        end
      end

      def dsl_exec(mod,&blk)
        mod.class_exec &blk
      end

      def self.evaluate(dsl, data={}, &blk)
        new.evaluate dsl, data, &blk
      end
    end
  end
end

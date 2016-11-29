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
        dsl_exec mod, &blk
        @finishers.reverse_each(&:call)
        clear_dsl_methods mod

        @processors.each do |processor|
          processor.build data
        end

        data
      end

      def process_dsl(dsl,data)
        return unless @dsls_seen.add? dsl
        cbs = dsl.generate(data)
        if cbs[:requires]
          cbs[:requires].each do |required_dsl|
            process_dsl Alki::Support.load_class(required_dsl), data
          end
        end
        @inits << cbs[:init] if cbs[:init]
        @finishers << cbs[:finish] if cbs[:finish]
        @processors << cbs[:processors] if cbs[:processors]
        if cbs[:methods]
          cbs[:methods].each do |name, proc|
            define_dsl_method data[:module], name, &proc
          end
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
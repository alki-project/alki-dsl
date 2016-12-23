require_relative '../test_helper'
require 'alki/class_builder'

describe Alki::ClassBuilder do
  describe :build do
    def build(data={})
      Alki::ClassBuilder.build data
    end

    it 'should create and return a new class' do
      build.must_be_instance_of Class
    end

    it 'should allow creation of modules' do
      build(type: :module).must_be_instance_of Module
    end

    it 'should allow setting instance methods' do
      obj = build(
        instance_methods: {
          test1: {
            body: -> { :test1 }
          },
          test2: {
            body: -> { :test2 },
            private: true
          }
        }
      ).new
      obj.test1.must_equal :test1
      assert_raises NoMethodError do
        obj.test2
      end
      obj.send(:test2).must_equal :test2
    end

    it 'should allow setting class methods' do
      klass = build(
        class_methods: {
          test1: {
            body: -> { :test1 }
          },
          test2: {
            body: -> { :test2 },
            private: true
          }
        }
      )
      klass.test1.must_equal :test1
      assert_raises NoMethodError do
        klass.test2
      end
      klass.send(:test2).must_equal :test2
    end

    it 'should allow setting super class' do
      super_class = Class.new
      build(super_class: super_class).superclass.must_equal super_class
    end

    it 'should allow setting super class by name' do
      class AlkiTestClass; end
      build(super_class: 'alki_test_class').superclass.must_equal AlkiTestClass
      Object.send :remove_const, :AlkiTestClass
    end

    it 'should include module and extend module::ClassMethods if provided' do
      m = Module.new do
        module self::ClassMethods
          def test1
            :test1
          end
        end
        def test2
          :test2
        end
      end
      klass = build(module: m)
      klass.included_modules.must_include m
      klass.test1.must_equal :test1
      klass.new.test2.must_equal :test2
    end

    it 'should include modules' do
      ms = [Module.new,Module.new]
      klass = build(modules: ms)
      ms.each do |m|
        klass.included_modules.must_include m
      end
    end

    it 'should extend class_modules' do
      ms = [
        Module.new { def test1; :test1; end },
        Module.new { def test2; :test2; end },
      ]
      klass = build(class_modules: ms)
      klass.test1.must_equal :test1
      klass.test2.must_equal :test2
    end

    it 'should create basic #initialize using initialize_params' do
      obj = build(initialize_params: [:a,:b]).new 1, 2
      obj.instance_variable_get(:@a).must_equal 1
      obj.instance_variable_get(:@b).must_equal 2
    end

    it 'should allow providing a constant name' do
      if defined?(AlkiTestClass)
        Object.send :remove_const, :AlkiTestClass
      end
      build(constant_name: "AlkiTestClass")
      assert(defined?(AlkiTestClass),'Expected AlkiTestClass to be defined')
      Object.send :remove_const, :AlkiTestClass
      assert(!defined?(AlkiTestClass))
    end

    it 'should use name to create class name' do
      if defined?(AlkiTest::TestClass)
        Object.send :remove_const, :AlkiTest
      end
      build(name: "alki_test/test_class")
      assert(defined?(AlkiTest::TestClass),'Expected AlkiTest::TestClass to be defined')
      Object.send :remove_const, :AlkiTest
    end

    it 'should allow creating secondary classes' do
      build(
        secondary_classes: [
          {
            constant_name: 'AlkiTestClass'
          }
        ]
      )
      assert(defined?(AlkiTestClass),'Expected AlkiTestClass to be defined')
      Object.send :remove_const, :AlkiTestClass
    end

    it 'should allow creating subclasses' do
      build(
        constant_name: 'AlkiTestClass',
        secondary_classes: [
          {
            subclass: 'Subclass'
          }
        ]
      )
      assert(defined?(AlkiTestClass::Subclass),'Expected AlkiTestClass::Subclass to be defined')
      Object.send :remove_const, :AlkiTestClass
    end
  end
end

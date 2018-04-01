require 'alki/feature_test'

describe 'Runtime requires' do
  before do
    foo_dsl = Alki::Dsl.build('alki/dsls/dsl') do
      dsl_method :foo do
        ctx[:result] = :foo
      end
    end

    @dsl = Alki::Dsl.build('alki/dsls/dsl') do
      dsl_method :load_foo do
        require_dsl foo_dsl
      end
    end
  end

  it 'should add the dsl methods to the running dsl' do
    @dsl.build do
      load_foo
      foo
    end.must_equal :foo
  end

  it 'should not add the dsl methods before it is required' do
    assert_raises NoMethodError do
      @dsl.build { foo }
    end
  end
end

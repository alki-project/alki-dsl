require 'alki/feature_test'

describe 'Build Context' do
  def foo
    :foo
  end

  before do
    @dsl = Alki::Dsl.build('alki/dsls/dsl') do
      dsl_method :result do |v|
        ctx[:result] = v
      end
    end
  end

  it 'should be accessable when evaluating a dsl' do
    @dsl.build { result foo }.must_equal :foo
  end
end

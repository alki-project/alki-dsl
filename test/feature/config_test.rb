require 'alki/feature_test'
require 'alki/dsl'

describe 'dsl configuration' do
  it 'should be automatically loaded when requiring a dsl' do
    require 'alki_test/dsls/number'
    AlkiTest::Dsls::Number.must_be_instance_of Class
    AlkiTest::Dsls::Number.singleton_methods.must_include :generate
  end

  it 'should allow using dsls specified in same dsl config' do
    require 'alki_test/numbers/three'
    AlkiTest::Numbers::Three.new.must_equal 3
  end
end

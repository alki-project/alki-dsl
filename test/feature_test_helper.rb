require 'alki/dsl'
$LOAD_PATH.unshift Alki::Test.fixture_path('example','lib')

class Minitest::Spec
  def build_dsl(&blk)
    Alki::Dsl.build 'alki/dsls/dsl', &blk
  end
end

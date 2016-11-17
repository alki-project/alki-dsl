$LOAD_PATH.unshift File.expand_path('../../lib',__FILE__)

require 'minitest/autorun'

class Minitest::Spec
  def root
    File.expand_path('../..',__FILE__)
  end

  def fixture_path(*path)
    File.join(root,'test','fixtures',*path)
  end
end

require 'alki/loader'

module Alki
  module Dsl
    def self.build(name,data={},&blk)
      Alki.load(name).build data, &blk
    end
  end
end


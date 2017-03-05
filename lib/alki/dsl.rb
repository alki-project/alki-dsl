require 'alki/loader'
require 'alki/dsl/merge'

module Alki
  module Dsl
    def self.merge(*dsls)
      Alki::Dsl::Merge.new *dsls
    end

    def self.build(name,data={},&blk)
      Alki.load(name).build data, &blk
    end
  end
end


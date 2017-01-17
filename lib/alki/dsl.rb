require 'alki/loader'
require 'alki/dsls/dsl'

module Alki
  module Dsl
    def self.merge(*dsls)
      Alki::Dsls::Dsl.build do
        dsls.each do |dsl|
          require_dsl dsl
        end
      end
    end

    def self.build(name,data={},&blk)
      Alki.load(name).build data, &blk
    end
  end
end


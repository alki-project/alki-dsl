require_relative '../test_helper'

require 'alki/dsl/loader'

describe Alki::Dsl::Loader do
  before do
    @fixtures_path = File.expand_path('../../fixtures',__FILE__)
    @config_path = File.join @fixtures_path, 'config.rb'
  end
  describe 'load' do
    before do
      @loader = Alki::Dsl::Loader.new @fixtures_path
    end

    it 'should load config file from root directory' do
      @loader.load(:config).call.must_equal 0
    end
  end

  describe 'self.load' do
    it 'should load a config file and call block with proc' do
      Alki::Dsl::Loader::load(@config_path).call.must_equal 0
    end

    it 'should be threadsafe' do
      t1 = Thread.new do
        $wait = 1
        Alki::Dsl::Loader::load(@config_path).call
      end
      sleep 0.5
      $wait = 0
      Alki::Dsl::Loader::load(@config_path).call.must_equal 0
      t1.value.must_equal 1
    end
  end
end
require 'alki/dsl/evaluator'
require 'alki/dsl/registry'

module Alki
  module Dsl
    def self.register(*args)
      Alki::Dsl::Registry.register *args
    end

    def self.register_dir(*args)
      Alki::Dsl::Registry.register_dir *args
    end

    def self.load(*args)
      Alki::Dsl::Loader.load(*args)
    end
  end
end

module Kernel
  def Alki(builder=nil,&blk)
    if blk
      loader_config = Thread.current[:alki_dsl_loader]
      result = if builder
        builder.build({}, &blk)
      elsif loader_config && loader_config[:builder]
        loader_config[:builder].build loader_config[:data], &blk
      else
        path = caller_locations(1,1)[0].absolute_path
        Alki::Dsl::Registry.build path, &blk
      end
      if loader_config
        Thread.current[:alki_dsl_loader][:result] = result
      end
    end
    ::Alki
  end
end

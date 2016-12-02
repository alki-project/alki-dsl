require 'alki/dsl/evaluator'
require 'alki/dsl/registry'

module Alki
  module Dsl
    @loaded = {}
    def self.[]=(path,value)
      @loaded[path] =value
    end

    def self.[](path)
      @loaded[path]
    end

    def self.register(*args)
      Alki::Dsl::Registry.register *args
    end

    def self.register_dir(*args)
      Alki::Dsl::Registry.register_dir *args
    end

    def self.load(path)
      path = File.absolute_path(path)
      require path
      self[path]
    end

    def self.build(name,data={},&blk)
      Alki::Support.load_class(name).build data, &blk
    end
  end
end

module Kernel
  def Alki(builder=nil,&blk)
    if blk
      path = caller_locations(1,1)[0].absolute_path
      result = if builder
        builder.build({}, &blk)
      else
        Alki::Dsl::Registry.build path, &blk
      end
      Alki::Dsl[path] = result
    end
    ::Alki
  end
end

require 'alki/dsl/base'

module Alki
  module Dsls
    class DslConfig < Alki::Dsl::Base
      def self.dsl_info
        {
          methods: %i(register register_dir register_lib_dir)
        }
      end

      def register(path,*args)
        path = File.expand_path(path,@ctx[:root])
        Alki::Dsl::Registry.register path, *args
      end

      def register_dir(path,*args)
        path = File.expand_path(path,@ctx[:root])
        Alki::Dsl::Registry.register_dir path, *args
      end

      def register_lib_dir(prefix,dsl,**data)
        path = File.join(@ctx[:root],'lib', prefix)
        Alki::Dsl::Registry.register_dir path, dsl, data.merge(prefix: prefix)
      end
    end
  end
end
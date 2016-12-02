require 'alki/dsl/loader'
require 'alki/support'

module Alki
  module Dsl
    module Registry
      @registered_paths = {}
      @registered_dirs = {}

      def self.register(path,builder,**data)
        @registered_paths[File.absolute_path(path)] = Entry.new(builder,data)
      end

      def self.register_dir(dir_path,builder,**data)
        @registered_dirs[File.join(File.absolute_path(dir_path),'')] = [builder,data]
      end

      def self.lookup(path, load_configs: true)
        path = File.absolute_path path
        entry = @registered_paths[path]
        return entry if entry

        @registered_dirs.each do |dir,(builder,data)|
          if path.start_with? dir
            data = {name: Alki::Support.path_name(path, dir)}.merge data
            return Entry.new(builder,data)
          end
        end

        if load_configs
          root = Alki::Support.find_root(path) do |dir|
            File.exists?(File.join(dir,'config','dsls.rb'))
          end
          if root
            config_file = File.join(root,'config','dsls.rb')
            register config_file, 'alki/dsls/dsl_config', root: root
            require config_file
            return lookup path, load_configs: false
          end
        end

        nil
      end

      def self.build(path,&blk)
        entry = lookup path
        if entry
          entry.build blk
        else
          nil
        end
      end

      class Entry
        def initialize(builder,data)
          @builder = builder
          @data = data
        end

        def build(blk)
          Alki::Support.load_class(@builder).build @data, &blk
        end
      end
    end
  end
end
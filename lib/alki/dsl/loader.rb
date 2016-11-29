require 'alki/support'
require 'alki/dsl'

module Alki
  module Dsl
    class Loader
      def self.load(config_file, builder = nil, **data)
        builder = Alki::Support.load_class builder if builder
        Fiber.new do
          Thread.current[:alki_dsl_loader] = {
            builder: builder,
            data: data,
            result: true,
          }
          Kernel.load config_file
          Thread.current[:alki_dsl_loader][:result]
        end.resume
      end

      def initialize(root_dir)
        @root_dir = root_dir
      end

      def all_paths
        Dir[File.join(@root_dir,'**','*.rb')].map do |path|
          path.gsub(File.join(@root_dir,''),'').gsub(/\.rb$/,'')
        end
      end

      def load_all
        all_paths.inject({}) do |h,path|
          h.merge!(path => Loader.load(path))
        end
      end

      def load(file)
        Loader.load File.expand_path("#{file}.rb",@root_dir)
      end
    end
  end
end

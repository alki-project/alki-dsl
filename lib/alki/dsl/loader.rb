require 'alki/support'
require 'alki/dsl'

module Alki
  module Dsl
    class Loader
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
          h.merge!(path => Alki::Dsl.load(path))
        end
      end

      def load(file)
        Alki::Dsl.load File.expand_path("#{file}.rb",@root_dir)
      end
    end
  end
end

require 'grit'

module GitBrowser

   class Repository < Grit::Repo

      attr :name

      def initialize(path, name)
         super(path)
         @name = name
      end

      def description
         if File.exists?(File.join(path, 'description'))
            super
         else
            'No description file.'
         end
      end
   end

   class RepositoriesList

      def initialize(root, excludes)
         @root = root
         @excludes = excludes
      end

      def excluded?(name)
         @excludes.include? name
      end

      def include?(name)
         return false if excluded?(name)
         Repository.new path(name), name
         true
      rescue Grit::InvalidGitRepositoryError
         false
      rescue Grit::NoSuchPathError
         false
      end
      alias exists? include?

      def get(name)
         Repository.new path(name), name
      end

      include Enumerable
      def each(&block)
         each_recurse @root, &block
      end

   private

      def each_recurse(directory, &block)
         Dir[File.join(directory, "*")].each do |path|
            next unless File.directory? path
            name = path.gsub(/^#{@root}\/?/, '')
            next if excluded? name
            begin
               repo = Repository.new(path, name)
            rescue Grit::InvalidGitRepositoryError
               each_recurse(path, &block)
               next
            end
            block[repo]
         end
      end

      def path(name)
         return File.join(@root, name)
      end
   end
end

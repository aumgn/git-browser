module GitBrowser

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
         Backend::Repository.new name, path(name)
         true
      rescue Backend::NoSuchRepository
         false
      end
      alias exists? include?

      def get(name)
         Backend::Repository.new name, path(name)
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
               repo = Backend::Repository.new(name, path)
            rescue Backend::NoSuchRepository
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

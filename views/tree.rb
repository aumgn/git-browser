module GitBrowser::App::Views

   class Tree < Layout

      class Entry

         def initialize(repo, branch, tree_blob)
            @repo = repo
            @branch = branch
            @tree_blob = tree_blob
         end

         def directory?
            @tree_blob.is_a? Grit::Tree
         end

         def icon
            directory? ? 'icon-folder-open' : 'icon-file'
         end

         def link
            link = "/#{@repo.name}"
            link << (directory? ? "/tree" : "blob")
            link << '/' << @branch
            link << '/' << @tree_blob.name
            link
         end

         def name
            @tree_blob.basename
         end

         def mode
            @tree_blob.mode
         end

         def size
            return nil if directory?
            "#{@tree_blob.size / 1000} kb"
         end
      end

      def parent?
         !!@parent
      end

      def parent
         @parent
      end

      def files
         @files.map { |file| Entry.new(@repo, @branch, file) }
      end
   end
end

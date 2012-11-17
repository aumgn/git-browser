module GitBrowser::App::Views

   class Tree < Layout

      class Entry

         def initialize(repo_path, tree_blob)
            @repo_path = repo_path
            @tree_blob = tree_blob
         end

         def directory?
            @tree_blob.is_a? Grit::Tree
         end

         def icon
            directory? ? 'icon-folder-open' : 'icon-file'
         end

         def link
            type = directory? ? 'tree' : 'blob'
            @repo_path.child_url type, @tree_blob.basename
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
         @repo_path.parent?
      end

      def parent
         @repo_path.parent_url
      end

      def files
         (@tree.trees + @tree.blobs).map do |tree_blob|
            Entry.new(@repo_path, tree_blob)
         end
      end
   end
end

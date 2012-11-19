module GitBrowser::App::Views

   class Tree < ProjectPageLayout

      class Entry

         def initialize(repobrowser, tree_blob)
            @repobrowser = repobrowser
            @tree_blob = tree_blob
         end

         def directory?
            @tree_blob.tree?
         end

         def icon
            directory? ? 'icon-folder-open' : 'icon-file'
         end

         def link
            type = directory? ? 'tree' : 'blob'
            @repobrowser.child_url type, @tree_blob.basename
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

      def breadcrumbs
         @repobrowser.path_breadcrumbs
      end

      def files_page?
         true
      end

      def parent?
         @repobrowser.parent?
      end

      def parent
         @repobrowser.parent_url
      end

      def files
         (@tree.trees + @tree.blobs).map do |tree_blob|
            Entry.new(@repobrowser, tree_blob)
         end
      end
   end
end

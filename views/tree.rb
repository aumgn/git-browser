module GitBrowser::App::Views

   class Tree < ProjectLayout

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
            @repobrowser.url type, child: @tree_blob.basename
         end

         def name
            @tree_blob.basename
         end

         def size
            return nil if directory?
            (@tree_blob.size.to_f / 1000).round.to_s + ' kb'
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
         @repobrowser.url('tree', child: '..')
      end

      def files
         (@tree.trees + @tree.blobs).map do |tree_blob|
            Entry.new(@repobrowser, tree_blob)
         end
      end
   end
end

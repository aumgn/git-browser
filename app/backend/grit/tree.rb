module GitBrowser::Backend::Grit

   class Tree

      def initialize(tree)
         @tree = tree
      end

      def tree?
         true
      end

      def blob?
         false
      end

      def basename
         @tree.basename
      end

      def mode
         @tree.mode
      end

      def size
         0
      end

      def trees
         @tree.trees.map { |tree| Tree.new(tree) }
      end

      def blobs
         @tree.blobs.map { |blob| Blob.new(blob) }
      end
   end
end

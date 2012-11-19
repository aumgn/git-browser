module GitBrowser::Backend::Rugged

   class Tree

      def self.for_info(repository, tree_info)
         new(repository, tree_info[:name], repository.lookup(tree_info[:oid]))
      end

      def initialize(repository, name, tree)
         @repository = repository
         @name = name
         @tree = tree
      end

      def tree?
         true
      end

      def blob?
         false
      end

      def basename
         @name
      end

      def mode
         ''
      end

      def size
         0
      end

      def trees
         trees = []
         @tree.each_tree { |tree| trees << Tree.for_info(@repository, tree) }
         trees
      end

      def blobs
         blobs = []
         @tree.each_blob { |blob| blobs << Blob.new(@repository, blob) }
         blobs
      end
   end
end

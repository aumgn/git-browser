module GitBrowser::Backend::Rugged

   class Blob

      include GitBrowser::FileTypes

      def initialize(repository, blob_info)
         @name = blob_info[:name]
         @blob = repository.lookup blob_info[:oid]
      end

      def tree?
         false
      end

      def blob?
         true
      end

      def basename
         @name
      end

      def mode
         ''
      end

      def size
         @blob.size
      end

      def data
         @blob.content
      end
   end
end

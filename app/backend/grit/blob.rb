module GitBrowser::Backend::Grit

   class Blob

      include GitBrowser::FileTypes

      def initialize(blob)
         @blob = blob
      end

      def tree?
         false
      end

      def blob?
         true
      end

      def basename
         @blob.basename
      end

      def size
         @blob.size
      end

      def data
         @blob.data
      end
   end
end

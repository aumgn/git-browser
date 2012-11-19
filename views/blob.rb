module GitBrowser::App::Views

   class Blob < ProjectPageLayout

      def files_page?
         true
      end

      def breadcrumbs
         @repobrowser.path_breadcrumbs
      end

      def sourcecode?
         true
      end

      def blob
         @blob.data
      end

      def filetype
         @blob.filetype
      end

      def image?
         @blob.image?
      end

      def markdown?
         @blob.filetype == 'markdown'
      end

      def sourcecode?
         !image? && !markdown? && @blob.filetype != 'binary'
      end

      def raw_link
         @repobrowser.url 'raw'
      end

      def blame_link
         @repobrowser.url 'blame'
      end

      def commits_link
         @repobrowser.url 'commits'
      end
   end
end

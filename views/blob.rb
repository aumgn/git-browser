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

      def file_type
         @file_type ||= get_file_type
      end

      def image?
         @blob.image?
      end

      def markdown?
         file_type == 'markdown'
      end

      def sourcecode?
         !image? && !markdown?
      end

      def raw_link
         @repobrowser.url 'raw'
      end

      def blame_link
         @repobrowser.url 'blame'
      end

   private

      def get_file_type
         language = @blob.language
         return nil if language.nil?
         return language.name.downcase
      end
   end
end

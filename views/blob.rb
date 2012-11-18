module GitBrowser::App::Views

   class Blob < Layout

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
         @repo_path.url 'raw'
      end

      def blame_link
         @repo_path.url 'blame'
      end

   private

      def get_file_type
         language = @blob.language
         return nil if language.nil?
         return language.name.downcase
      end
   end
end

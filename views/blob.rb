module GitBrowser::App::Views

   class Blob < Layout

      ImagesType = [ 'png', 'jpg', 'gif', 'jpeg', 'bmp' ]

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
         file_type == 'image'
      end

      def markdown?
         file_type == 'markdown'
      end

      def sourcecode?
         !image? && !markdown?
      end

   private

      def get_file_type
         split = @blob.basename.split('.')
         return 'image' if split.size > 1 and ImagesType.include?(split[-1])
         language = @blob.language
         return nil if language.nil?
         return language.name.downcase
      end
   end
end

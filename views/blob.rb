module GitBrowser::App::Views

   class Blob < Layout

      def sourcecode?
         true
      end

      def blob
         @blob.data
      end
   end
end

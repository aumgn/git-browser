class GitBrowser::App

   module Views

      class Layout < Mustache

         def project_page?
            false
         end
      end
   end
end


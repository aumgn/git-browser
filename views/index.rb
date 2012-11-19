module GitBrowser::App::Views

   class Index < Layout

      def repositories
         @repositories.map { |repo| {
            name: repo.display_name,
            index_link: "/#{repo.name}/tree",
            description: repo.display_description,
         } }
      end
   end
end

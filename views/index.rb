module GitBrowser::App::Views

   class Index < Layout

      def repositories
         @repositories.map { |repo| {
            name: repo.display_name,
            index_link: "/#{repo.name}/tree",
            rss_link: '/',
            description: repo.description,
         } }
      end
   end
end

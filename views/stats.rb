module GitBrowser::App::Views

   class Stats < ProjectLayout

      breadcrumbs 'Statistics'

      def stats_page?
         true
      end
   end
end

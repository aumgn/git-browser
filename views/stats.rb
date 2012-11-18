module GitBrowser::App::Views

   class Stats < ProjectPageLayout

      breadcrumbs 'Statistics'

      def stats_page?
         true
      end
   end
end

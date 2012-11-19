module GitBrowser::App::Views

   class BlameLines

      def initialize(blamelines)
         @blamelines = blamelines
      end

      def commit_link
         '/'
      end

      def commit_short_hash
         @blamelines.commit.short_hash
      end

      def lines
         p @blamelines.lines
         @blamelines.lines * "\n"
      end
   end

   class Blame < ProjectPageLayout

      breadcrumbs 'Blame'

      def commits_page?
         true
      end

      def name
         @blob.basename
      end

      def blames
         @blame.lines.map { |blamelines| BlameLines.new(blamelines) }
      end
   end
end

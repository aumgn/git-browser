module GitBrowser::App::Views

   class BlameLines

      def initialize(repobrowser, blamelines)
         @repobrowser = repobrowser
         @blamelines = blamelines
      end

      def commit_link
         @repobrowser.commit_url @blamelines.commit
      end

      def commit_short_hash
         @blamelines.commit.short_hash
      end

      def lines
         @blamelines.lines * "\n"
      end
   end

   class Blame < ProjectLayout

      breadcrumbs 'Blame'

      def commits_page?
         true
      end

      def name
         @blob.basename
      end

      def blames
         @blame.lines.map do |blamelines|
            BlameLines.new(@repobrowser, blamelines)
         end
      end
   end
end

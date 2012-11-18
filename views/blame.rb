module GitBrowser::App::Views

   class BlameLines

      def initialize(blame_lines)
         @commit = blame_lines[0]
         @lines = blame_lines[1]
      end

      def commit_link
         '/'
      end

      def commit_short_hash
         @commit.id_abbrev
      end

      def lines
         @lines * "\n"
      end
   end

   class Blame < ProjectPageLayout

      def commits_page?
         true
      end

      def name
         @blob.basename
      end

      def blames
         @blame.map { |b| BlameLines.new(b) }
      end
   end
end

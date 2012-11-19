require_relative 'diff'

module GitBrowser::Backend::Grit

   class Commit

      class Author

         def initialize(author)
            @author = author
         end

         def name
            @author.name
         end

         def email
            @author.email
         end
      end

      def initialize(commit)
         @commit = commit
      end

      def date
         @commit.date
      end

      def short_hash
         @commit.id_abbrev
      end

      def message
         @commit.message
      end

      def author
         Author.new(@commit.author)
      end

      def stats
         @commit.stats.to_diffstat.map { |stat| Stat.new(stat) }
      end

      def diffs
         @commit.diffs.map { |diff| Diff.new(diff) }
      end
   end
end

module GitBrowser::Backend::Grit

   class Stat

      def initialize(stat)
         @stat = stat
      end

      def filename
         @stat.filename
      end

      def additions
         @stat.additions
      end

      def deletions
         @stat.deletions
      end

      def net
         @stat.net
      end
   end

   class Diff

      def initialize(diff)
         @diff = diff
      end

      def new_path
         @diff.b_path
      end

      def content
         @diff.diff
      end
   end
end

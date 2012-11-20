module GitBrowser::Backend::Grit

   class Stat

      include GitBrowser::FileTypes

      def initialize(stat)
         @stat = stat
      end

      def basename
         File.basename filename
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

      include GitBrowser::FileTypes

      def initialize(diff)
         @diff = diff
      end

      def basename
         File.basename new_path
      end

      def new_path
         @diff.b_path
      end

      def content
         @diff.diff
      end
   end
end

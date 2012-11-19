module GitBrowser::Backend::Grit

   class BlameLines

      def initialize(blamelines)
         @commit = Commit.new(blamelines[0])
         @lines = blamelines[1]
      end

      def commit
         @commit
      end

      def lines
         @lines
      end
   end

   class Blame

      def initialize(blame)
         @blame = blame
      end

      def lines
         @blame.map { |blamelines| BlameLines.new(blamelines) }
      end
   end
end

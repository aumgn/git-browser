module GitBrowser::App::Views

   class DiffStat

      def initialize(index, diffstat)
         @index = index
         @stat = diffstat
      end

      def id
         "diff-#{@index}"
      end

      def name
         @stat.filename
      end

      def summary
         "A#{@stat.additions} D#{@stat.deletions} N#{@stat.net}"
      end
   end

   class Diff

      def initialize(index, diff)
         @index = index
         @diff = diff
      end

      def id
         "diff-#{@index}"
      end

      def name
         @diff.b_path
      end

      def lines
         counter = Struct.new(:old_line, :new_line).new(1, 1)
         @diff.diff.each_line.to_a[3..-1].map do |line|
            DiffLine.new(counter, line)
         end
      end
   end

   class DiffLine

      def initialize(counter, line)
         @line = line

         @old_number = counter.old_line
         @new_number = counter.new_line

         @old_number = counter.old_line
         @new_number = counter.new_line
         if @line[0] == ?-
            @type = 'old'
            counter.old_line += 1
            @new_number = nil
         elsif @line[0] == ?+
            @type = 'new'
            counter.new_line += 1
            @old_number = nil
         else
            @type = nil
            counter.old_line += 1
            counter.new_line += 1
         end
      end

      def old_number
         @old_number
      end

      def new_number
         @new_number
      end

      def type
         return 'new' if @line[0] == ?+
         return 'old' if @line[0] == ?-
         return nil
      end

      def content
         @line
      end
   end

   class Commit < Layout

      def browse_link
         '/'
      end

      def message
         @commit.message
      end

      def author
         @author ||= @commit.author
      end

      def author_name
         author.name
      end

      def author_email
         @author_email ||= author.email
      end

      def author_avatar32
         avatar_digest = Digest::MD5.hexdigest(author_email)
         "http://gravatar.com/avatar/#{avatar_digest}?s=32"
      end

      def date
         @commit.date.strftime('%d/%m/%Y at %H:%M:%S')
      end

      def diffs_stat
         @commit.stats.to_diffstat.each_with_index.map do |diff, index|
            DiffStat.new(index, diff)
         end
      end

      def diffs
         @diffs ||= @commit.diffs.each_with_index.map do |diff, index|
            Diff.new(index, diff)
         end
      end

      def changed_files
         diffs.size
      end
   end
end

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

      def binary?
         @stat.binary? or @stat.image?
      end

      def summary
         return 'Binary' if binary?
         "+#{@stat.additions} -#{@stat.deletions} ~#{@stat.net}"
      end
   end

   class Diff

      LineCounter = Struct.new(:old_line, :new_line)

      def initialize(repobrowser, commit, index, diff)
         @repobrowser = repobrowser
         @commit = commit
         @index = index
         @diff = diff
      end

      def id
         "diff-#{@index}"
      end

      def name
         @diff.new_path
      end

      def binary?
         @diff.binary? or @diff.image?
      end

      def lines
         counter = LineCounter.new(1, 1)
         i = 0
         @diff.content.each_line.to_a.map do |line|
            (i += 1; next) if i < 2
            DiffLine.new(counter, line)
         end
      end

      def short_hash
         @commit.short_hash
      end

      def history_link
         @repobrowser.url 'commits', path: @diff.new_path
      end

      def view_link
         @repobrowser.url 'blob', path: @diff.new_path
      end
   end

   class DiffLine

      HUNK_HEADER_PATTERN = /^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@/

      attr_reader :content, :type, :old_number, :new_number

      def initialize(counter, line)
         @content = line

         if line =~ HUNK_HEADER_PATTERN
            @type = 'chunk'
            counter.old_line = $1.to_i
            counter.new_line = $2.to_i
            @old_number = '...'
            @new_number = '...'
            return
         end

         @old_number = counter.old_line
         @new_number = counter.new_line
         if line[0] == ?-
            @type = 'old'
            counter.old_line += 1
            @new_number = nil
         elsif line[0] == ?+
            @type = 'new'
            counter.new_line += 1
            @old_number = nil
         else
            @type = nil
            counter.old_line += 1
            counter.new_line += 1
         end
      end
   end

   class Commit < ProjectLayout

      def breadcrumps
         [{ directory: "Commit #{@commit.short_hash}", path: '' }]
      end

      def commits_page?
         true
      end

      def browse_link
         @repobrowser.url 'tree', reference: @commit.short_hash, path: nil
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

      def stats
         @commit.stats.each_with_index.map do |diff, index|
            DiffStat.new(index, diff)
         end
      end

      def diffs
         @diffs ||= @commit.diffs.each_with_index.map do |diff, index|
            Diff.new(@repobrowser, @commit, index, diff)
         end
      end

      def changed_files
         diffs.size
      end
   end
end


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
         counter = Struct.new(:old_line, :new_line).new(1, 1)
         @diff.content.each_line.to_a[3..-1].map do |line|
            DiffLine.new(counter, line)
         end
      end

      def short_hash
         @commit.short_hash
      end

      def history_link
         @repobrowser.url_for_path('commits', @diff.new_path)
      end

      def view_link
         @repobrowser.url_for_path('blob', @diff.new_path)
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

   class Commit < ProjectPageLayout

      def breadcrumps
         [{ directory: "Commit #{@commit.short_hash}", path: '' }]
      end

      def commits_page?
         true
      end

      def browse_link
         @repobrowser.url_for_reference 'tree', @commit.short_hash
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

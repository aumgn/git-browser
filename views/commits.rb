require 'digest/md5'

module GitBrowser::App::Views

   class CommitEntry

      attr_reader :link, :short_hash, :date, :message
      attr_reader :author_avatar, :author_name, :author_email

      def initialize(commit)
         @link = '/'
         @short_hash = commit.id_abbrev
         @date = commit.date.strftime('%d/%m/%Y at %H:%M:%S')
         @message = commit.message.split("\n")[0]

         author = commit.author
         @author_name = author.name
         @author_email = author.email
         @author_avatar = 'http://placehold.it/40x40'
         avatar_digest = Digest::MD5.hexdigest(@author_email)
         @author_avatar = "http://gravatar.com/avatar/#{avatar_digest}?s=40"
      end
   end

   class CommitsByDate

      attr_reader :date, :commits

      def initialize(date, commits)
         @date = date
         @commits = commits.map { |c| CommitEntry.new(c) }
      end
   end

   class Commits < ProjectPageLayout

      def commits_page?
         true
      end

      def commits_by_dates
         @by_date ||= @commits.group_by do |c|
            c.date.strftime('%m/%d/%Y')
         end.map { |date, commit| CommitsByDate.new(date, commit) }
      end
   end
end

require 'digest/md5'

module GitBrowser::App::Views

   class CommitEntry

      attr_reader :link, :short_hash, :date, :message
      attr_reader :author_avatar, :author_name, :author_email

      def initialize(repobrowser, commit)
         @link = repobrowser.commit_url commit
         @short_hash = commit.short_hash
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

      def initialize(repobrowser, date, commits)
         @date = date
         @commits = commits.map { |c| CommitEntry.new(repobrowser, c) }
      end
   end

   class Commits < ProjectLayout

      breadcrumbs 'Commit history'

      def commits_page?
         true
      end

      def commits_by_dates
         @by_date ||= @commitspager.commits.group_by do |c|
            c.date.strftime('%d/%m/%Y')
         end.map do |date, commit|
            CommitsByDate.new(@repobrowser, date, commit)
         end
      end

      def pager
         @commitspager
      end
   end
end

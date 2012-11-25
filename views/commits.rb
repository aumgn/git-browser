require 'digest/md5'

module GitBrowser::App::Views

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

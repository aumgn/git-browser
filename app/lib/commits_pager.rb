module GitBrowser

   class CommitsPager

      def initialize(repobrowser, page)
         @commits_per_page = GitBrowser::Config.commits_per_page
         @repobrowser = repobrowser
         @page = page
      end

      def commits
         @repobrowser.commits(@commits_per_page, @page * @commits_per_page)
      end

      def previous_page?
         @page > 0
      end

      def previous_page_url
         page_url(@page - 1)
      end

      def next_page?
         @page < total_pages
      end

      def next_page_url
         page_url(@page + 1)
      end

   private

      def page_url(page)
         "#{@repobrowser.url('commits')}?page=#{page}"
      end

      def total_pages
         @total_pages ||= @repobrowser.repo.total_commits / @commits_per_page
      end
   end
end

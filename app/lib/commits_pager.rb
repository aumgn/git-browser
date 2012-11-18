module GitBrowser

   class CommitsPager

      @commits_per_page = 15
      class << self
         attr_accessor :commits_per_page
      end

      def initialize(repobrowser, page)
         @commits_per_page = self.class.commits_per_page
         @repobrowser = repobrowser
         @page = page
      end

      def commits
         @repobrowser.repo.commits(@repobrowser.reference, @commits_per_page,
               @page * @commits_per_page)
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
         "#{@repobrowser.url_without_path('commits')}?page=#{page}"
      end

      def total_pages
         @total_pages ||= @repobrowser.repo.commit_count / @commits_per_page
      end
   end
end
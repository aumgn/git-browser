module GitBrowser::App::Views

   class ProjectLayout < Layout

      def self.breadcrumbs(directory, path = '')
         class_eval <<-END
         def breadcrumbs
            [{ directory: '#{directory}', path: '#{path}' }]
         end
         END
      end

      def project_page?
         true
      end

      def branches?
         true
      end

      def repository_name
         @repobrowser.repo.display_name
      end

      def repository_url
         @repobrowser.url 'tree', reference: nil, path: nil
      end

      def breadcrumbs_it
         breadcrumbs = breadcrumbs()
         breadcrumbs[-1][:last?] = true unless breadcrumbs.empty?
         breadcrumbs
      end

      def breadcrumbs
         []
      end

      def archive_formats
         formats = GitBrowser::Backend::Repository.archive_formats
         formats.map do |name, format|
            {
               current_branch: @repobrowser.reference,
               name: format.extension.upcase,
               link: @repobrowser.url("#{name}ball", path: nil),
            }
         end
      end

      def current_branch
         @repobrowser.reference
      end

      def branches
         wrap_references @repobrowser.repo.heads
      end

      def tags?
         !tags.empty?
      end

      def tags
         @tags ||= wrap_references @repobrowser.repo.tags
      end

      def files_page?
         false
      end

      def commits_page?
         false
      end

      def nav_files_link
         nav_link 'tree'
      end

      def nav_commits_link
         nav_link 'commits'
      end

      def stats_page?
         false
      end

      def stats_link
         @repobrowser.url 'stats', reference: nil, path: nil
      end

      def last_commit
         CommitEntry.new(@repobrowser, @repobrowser.last_commit)
      end

   private

      def nav_link(type)
         ref = @repobrowser.head_reference? ? @repobrowser.reference : nil
         @repobrowser.url type, reference: ref, path: nil
      end

      def wrap_references(references)
         return [] if references.nil?
         url_type = commits_page? ? 'commits' : 'tree'
         references.map do |ref|
            {
               name: ref,
               url: @repobrowser.url(url_type, reference: ref, path: nil)
            }
         end
      end
   end
end

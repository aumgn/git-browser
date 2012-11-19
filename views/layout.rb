class GitBrowser::App

   module Views

      class Layout < Mustache

         def project_page?
            false
         end
      end

      class ProjectPageLayout < Layout

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
            @repobrowser.url_without_reference 'tree'
         end

         def breadcrumbs_it
            b = breadcrumbs.each { |b| { last?: false }.merge(b) }
            b[-1][:last?] = true unless b.empty?
            b
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
                  link: @repobrowser.url_without_path("#{name}ball"),
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

         def files_link
            @repobrowser.url_without_path 'tree'
         end

         def commits_page?
            false
         end

         def commits_link
            @repobrowser.url_without_path 'commits'
         end

         def stats_page?
            false
         end

         def stats_link
            @repobrowser.url_without_reference 'stats'
         end

         private

         def wrap_references(references)
            return [] if references.nil?
            references.map do |ref|
               {
                  name: ref,
                  url: @repobrowser.url_for_reference('tree', ref)
               }
            end
         end
      end
   end
end


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
            @repobrowser.repository_name
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

         def current_branch
            @repobrowser.reference
         end

         def branches
            wrap_references @repobrowser.branches
         end

         def tags?
            !tags.empty?
         end

         def tags
            @tags ||= wrap_references @repobrowser.tags
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

         def tar_link
            @repobrowser.url_without_path 'tarball'
         end

         def targz_link
            @repobrowser.url_without_path 'targzball'
         end

      private

         def wrap_references(references)
            references.map do |ref|
               {
                  name: ref.name,
                  url: @repobrowser.url_for_reference('tree', ref.name)
               }
            end
         end
      end
   end
end

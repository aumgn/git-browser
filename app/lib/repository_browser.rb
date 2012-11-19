require_relative 'commits_pager'

module GitBrowser

   class RepositoryBrowser

      attr_reader :repo, :reference

      def initialize(repo_name, reference = nil, path = nil)
         raise RepositoryNotFound unless Repositories.exists? repo_name
         @repo = Repositories.get repo_name
         self.reference = reference
         self.path = path unless path.nil?
      end

      def reference=(reference)
         reference ||= 'master'
         raise ReferenceNotFound unless @repo.valid_reference?(reference)
         @reference = reference
      end

      def path
         @path
      end

      def path=(path)
         @path = path
      end

      def path_breadcrumbs
         breadcrumbs = []
         unless path.nil?
            url = url_without_path 'tree'
            @path.split('/').map do |fragment|
               url = url + '/' + fragment
               breadcrumbs << { directory: fragment, url: url }
            end
         end
         breadcrumbs
      end

      def parent?
         !@path.nil?
      end

      def url(type)
         url_for_path(type, path)
      end

      def url_without_reference(type)
         "/#{@repo.name}/#{type}"
      end

      def url_for_reference(type, new_reference)
         "/#{@repo.name}/#{type}/#{new_reference || 'master'}"
      end

      def url_without_path(type)
         url_for_reference type, reference
      end

      def url_for_path(type, path)
         url = "/#{@repo.name}/#{type}/#{reference}/#{path.to_s}"
         url[-1] == ?/ ? url[0...-1] : url
      end

      def commit_url(commit)
         url_without_reference('commit') << '/' << commit.short_hash
      end

      def child_url(type, name)
         "#{url type}/#{name}"
      end

      def parent_url
         child_url('tree', '..')
      end

      def tree
         tree = @repo.tree_or_blob(reference, path)
         raise NotATree unless tree.tree?
         tree
      end

      def blob
         blob = @repo.tree_or_blob(reference, path)
         raise NotABlob unless blob.blob?
         blob
      end

      def commits(number, skip)
         @repo.commits(reference, path, number, skip)
      end

      def commits_pager(page)
         CommitsPager.new(self, page)
      end

      def commit
         @repo.commit(reference)
      end

      def blame
         @repo.blame(reference, path)
      end

      def archive(format)
         @repo.archive(format, reference)
      end

      class Error < RuntimeError
      end

      class RepositoryNotFound < Error
         def message
            'Repository not found'
         end
      end

      class ReferenceNotFound < Error
         def message
            'Reference not found'
         end
      end

      class TreeBlobNotFound < Error
         def message
            'Neither a tree nor a blob'
         end
      end

      class NotATree < Error
         def message
            'Not a tree'
         end
      end

      class NotABlob < Error
         def message
            'Not a blob'
         end
      end
   end
end

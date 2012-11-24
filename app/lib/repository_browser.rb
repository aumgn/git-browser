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
            url = url 'tree', path: nil
            path.split('/').map do |fragment|
               url = url + '/' + fragment
               breadcrumbs << { directory: fragment, url: url }
            end
         end
         breadcrumbs
      end

      def parent?
         !path.nil?
      end

      def url(type, options = {})
         '/' + [
            options.has_key?(:repo)      ? options[:repo]      : @repo.name,
            type,
            options.has_key?(:reference) ? options[:reference] : reference,
            options.has_key?(:path)      ? options[:path]      : path,
            options.has_key?(:child)     ? options[:child]     : nil
         ].compact * '/'
      end

      def commit_url(commit)
         "/#{@repo.name}/commit/#{commit.short_hash}"
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

require_relative 'commits_pager'

module GitBrowser

   class RepositoryBrowser

      attr_reader :repo, :reference

      def initialize(repo_name, reference = nil, path = nil)
         raise RepositoryNotFound unless Repositories.exists? repo_name
         @repo = Repositories.get repo_name
         self.reference = reference || 'master'
         self.path = path unless path.nil?
      end

      def repository_name
         @repo.display_name
      end

      def reference=(reference)
         reference ||= 'master'
         if !@repo.is_head?(reference) and @repo.commit(reference).nil?
            raise ReferenceNotFound
         end
         @reference = reference
      end

      def path
         @path
      end

      def path=(path)
         @path = path
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
         url_without_reference('commit') << '/' << commit.id_abbrev
      end

      def child_url(type, name)
         "#{url type}/#{name}"
      end

      def parent_url
         child_url('tree', '..')
      end

      def branches
         @repo.heads
      end

      def tags
         @repo.tags
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

      def tree_blob
         tree_blob = @repo.tree(reference)
         unless @path.nil?
            tree_blob = tree_blob / @path
            raise TreeBlobNotFound if tree_blob.nil?
         end
         tree_blob
      end

      def tree
         tree = tree_blob
         raise NotATree unless tree.is_a? Grit::Tree
         tree
      end

      def blob
         blob = tree_blob
         raise NotABlob unless blob.is_a? Grit::Blob
         blob
      end

      def blame
         Grit::Blob.blame(@repo, reference, path)
      end

      def commits(number, skip)
         @repo.log(reference, path || '.', n: number, skip: skip)
      end

      def commits_pager(page = 0)
         CommitsPager.new(self, page)
      end

      def commit
         @repo.commit(reference)
      end

      def archive(format)
         if format == 'tar'
            @repo.archive_tar reference
         else
            @repo.archive_tar_gz reference
         end
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



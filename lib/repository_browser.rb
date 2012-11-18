module GitBrowser

   class RepositoryBrowser

      COMMITS_PER_PAGE = 15

      class Error              < RuntimeError ; end
      class RepositoryNotFound < Error        ; end
      class ReferenceNotFound  < Error        ; end
      class TreeBlobNotFound   < Error        ; end
      class NotATree           < Error        ; end
      class NotABlob           < Error        ; end

      def initialize(repo_name, reference = nil, path = nil)
         raise RepositoryNotFound unless Repositories.exists? repo_name
         @repo = Repositories.get repo_name
         self.reference = reference unless reference.nil?
         self.path = path unless path.nil?
      end

      def reference
         @reference || 'master'
      end

      def reference=(reference)
         raise ReferenceNotFound unless @repo.is_head? reference
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
         url = "/#{@repo.name}/#{type}/#{reference}/#{path.to_s}"
         url[-1] == ?/ ? url[0...-1] : url
      end

      def child_url(type, name)
         "#{url type}/#{name}"
      end

      def parent_url
         child_url('tree', '..')
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

      def commits(page = 0)
         @repo.commits(reference, COMMITS_PER_PAGE, page * COMMITS_PER_PAGE)
      end

      def commit(id)
         @repo.commit(id)
      end
   end
end

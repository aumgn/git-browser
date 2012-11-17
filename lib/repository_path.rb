module GitBrowser

   class RepositoryPath

      class Error < RuntimeError
      end

      class RepositoryNotFound < Error
      end

      class ReferenceNotFound < Error
      end

      class InvalidFilePath < Error
      end

      def initialize(repo_name, reference, filepath)
         raise RepositoryNotFound unless Repositories.exists? repo_name
         @repo = Repositories.get repo_name

         raise HeadNotFound unless @repo.is_head? reference
         @reference = reference

         @tree_blob = @repo.tree(reference)
         raise ReferenceNotFound if @tree_blob.nil?
         if filepath.nil?
            @has_parent = false
         else
            @has_parent = true
            @tree_blob = @tree_blob / filepath
            raise InvalidFilePath if tree_blob.nil?
         end
         @filepath = filepath
      end

      def url(type)
         url = "/#{@repo.name}/#{type}/#@reference/#@filepath"
         url[-1] == ?/ ? url[0...-1] : url
      end

      def child_url(type, name)
         "#{url type}/#{name}"
      end

      def parent?
         return @has_parent
      end

      def parent_url
         child_url('tree', '..')
      end

      def tree_blob
         @tree_blob
      end
   end
end

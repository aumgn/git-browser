require 'grit'

require_relative 'tree'
require_relative 'blob'
require_relative 'commit'
require_relative 'blame'

module GitBrowser::Backend

   module Grit

      class Repository < BaseRepository

         def self.archive_formats
            {
               'tar'   => ArchiveFormat.new('tar',    'application/x-tar'),
               'targz' => ArchiveFormat.new('tar.gz', 'application/x-tgz'),
            }
         end

         def initialize(name, path)
            super(name, path)
            @repo = ::Grit::Repo.new(path)
         rescue ::Grit::InvalidGitRepositoryError, ::Grit::NoSuchPathError
            raise NoSuchRepository.new(path)
         end

         def path
            @repo.path
         end

         def name
            @name ||= File.basename path
         end

         def description
            @repo.description
         end

         def valid_reference?(reference)
            @repo.is_head?(reference) || !@repo.commit(reference).nil?
         end

         def heads
            @repo.heads.map { |head| head.name }
         end

         def tags
            @repo.tags.map { |head| head.name }
         end

         def total_commits
            @repo.commit_count
         end

         def tree_or_blob(reference, path)
            tree_blob = @repo.tree(reference)
            tree_blob = tree_blob / path unless path.nil?

            if tree_blob.is_a? ::Grit::Tree
               return Tree.new(tree_blob)
            else
               return Blob.new(tree_blob)
            end
         end

         def blame(reference, path)
            Blame.new ::Grit::Blob.blame(@repo, reference, path)
         end

         def commits(reference, path, number, skip)
            commits = @repo.log(reference, path || '.', n: number, skip: skip)
            commits.map { |commit| Commit.new(commit) }
         end

         def commit(id)
            Commit.new(@repo.commit(id))
         end

         def archive(format, reference)
            if format == 'tar'
               @repo.archive_tar reference
            else
               @repo.archive_tar_gz reference
            end
         end
      end
   end
end

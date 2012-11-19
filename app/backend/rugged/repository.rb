require 'rugged'

require_relative '../grit/repository'
require_relative 'tree'
require_relative 'blob'

module GitBrowser::Backend

   module Rugged

      class Repository < Grit::Repository

         def initialize(name, path)
            super(name, path)
            @repository = ::Rugged::Repository.new(path)
         end

         def heads
            load_references
            @heads.keys
         end

         def tags
            load_references
            @tags.keys
         end

         def tree_or_blob(reference, path)
            commit = resolve(reference)
            return Tree.new(@repository, '', commit.tree) if path.nil?
            fragments = path.split('/')
            parent = fragments[0..-2].inject(commit.tree) do |tree, fragment|
               subtree = tree[fragment]
               return nil if subtree.nil? or subtree[:type] != :tree
               @repository.lookup subtree[:oid]
            end

            tree_blob = parent[fragments[-1]]
            return nil if tree_blob.nil?
            return Blob.new(@repository, tree_blob) if tree_blob[:type] == :blob
            return Tree.for_info(@repository, tree_blob)
         end

      private

         def load_references
            return unless @heads.nil? or @tags.nil?
            @heads = {}
            @tags = {}
            @repository.refs.each do |ref|
               next unless ref =~ %r{^/?refs/(heads|tags)/(.+)$}
               ($1 == 'heads' ? @heads : @tags)[$2] = ref
            end
         end

         def resolve(reference)
            load_references
            if @heads.has_key? reference
               oid = ::Rugged::Reference.lookup(@repository,
                     @heads[reference]).target
            elsif @tags.has_key? reference
               oid = ::Rugged::Reference.lookup(@repository,
                     @tags[reference]).target
            else
               oid = reference
            end
            @repository.lookup(oid)
         end
      end
   end
end

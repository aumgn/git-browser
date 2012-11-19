require_relative '../grit/repository'

require 'rugged'

module GitBrowser::Backend

   module Rugged

      class Repository < Grit::Repository

         def initialize(name, path)
            super(name, path)
            @repository = ::Rugged::Repository.new(path)
         end

         def heads
            load_references
            @heads
         end

         def tags
            load_references
            @tags
         end

      private

         def load_references
            return unless @heads.nil? or @tags.nil?
            @heads = []
            @tags = []
            @repository.refs.each do |ref|
               next unless ref =~ %r{^refs/(heads|tags)/(.+)$}
               ($1 == 'heads' ? @heads : @tags) << $2
            end
         end
      end
   end
end

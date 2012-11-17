require 'sinatra/base'
require 'mustache/sinatra'
require './lib/repository_path'

module GitBrowser

   class App < Sinatra::Base
      set :environment, GitBrowser::Env
      set :root, GitBrowser::Root

      register Mustache::Sinatra
      require './views/layout'
      set :mustache, {
         :views => './views/',
         :templates => 'templates/'
      }

      helpers do

         def tree(repo_name, reference = 'master', path = nil)
            @repo_path = RepositoryPath.new(repo_name, reference, path)
            @tree = @repo_path.tree_blob
            raise Sinatra::NotFound unless @tree.is_a? Grit::Tree
            mustache :tree
         rescue RepositoryPath::Error
            raise Sinatra::NotFound
         end
      end

      get '/' do
         @repositories = Repositories.map.to_a
         mustache :index
      end

      get %r{/(.+)/tree/?$} do |repo_name|
         tree repo_name
      end

      get %r{/(.+)/tree/([^/]+)/?$} do |repo_name, reference|
         tree repo_name, reference
      end

      get %r{/(.+)/tree/([^/]+)/(.+)/?$} do |repo_name, reference, path|
         tree repo_name, reference, path
      end

      get %r{/(.+)/blob/([^/]+)/(.+)$} do |repo_name, reference, path|
         begin
            @repo_path = RepositoryPath.new(repo_name, reference, path)
         rescue RepositoryPath::Error
            raise Sinatra::NotFound
         end
         @blob = @repo_path.tree_blob
         raise Sinatra::NotFound unless @blob.is_a? Grit::Blob
         mustache :blob
      end
   end
end

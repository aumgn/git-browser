require 'sinatra/base'
require 'mustache/sinatra'

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
         def tree(repo_name, branch = 'master', path = nil)
            pass unless Repositories.exists? repo_name
            @repo = Repositories.get repo_name
            raise Sinatra::NotFound unless @repo.is_head? branch
            if path.nil?
               @parent = nil
               @tree = @repo.tree branch
            else
               path = path + '/' unless path[-1] == ?/
               @parent = '/'
               @tree = @repo.tree branch, path + '/'
               raise Sinatra::NotFound if @tree.nil?
            end
            @branch = branch
            @files = @tree.trees + @tree.blobs
            mustache :tree
         end
      end

      get '/' do
         @repositories = Repositories.map.to_a
         mustache :index
      end

      get %r{/(.+)/tree/?$} do |repo|
         tree repo
      end

      get %r{/(.+)/tree/([^/]+)/?$} do |repo, branch|
         tree repo, branch
      end

      get %r{/(.+)/tree/([^/]+)/(.+)$} do |repo, branch, path|
         tree repo, branch, path
      end
   end
end

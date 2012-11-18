require 'sinatra/base'
require 'mustache/sinatra'
require './lib/repository_path'
require './lib/file_types'

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

      COMMITS_PER_PAGE = 15

      helpers do

         def tree(repo_name, reference = 'master', path = nil)
            @repo_path = RepositoryPath.new(repo_name, reference, path)
            @tree = @repo_path.tree_blob
            raise Sinatra::NotFound unless @tree.is_a? Grit::Tree
            mustache :tree
         rescue RepositoryPath::Error
            raise Sinatra::NotFound
         end

         def blob_for(repo_name, reference, path)
            begin
               @repo_path = RepositoryPath.new(repo_name, reference, path)
            rescue RepositoryPath::Error
               raise Sinatra::NotFound
            end
            blob = @repo_path.tree_blob
            raise Sinatra::NotFound unless blob.is_a? Grit::Blob
            blob
         end

         def commits(repo_name, reference = 'master')
            raise Sinatra::NotFound unless Repositories.exists? repo_name
            @repo = Repositories.get repo_name

            raise Sinatra::NotFound unless @repo.is_head? reference
            @reference = reference

            @page = params[:page] || 0
            @commits = @repo.commits(reference, COMMITS_PER_PAGE,
               @page * COMMITS_PER_PAGE)
            mustache :commits
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
         @blob = blob_for repo_name, reference, path
         mustache :blob
      end

      get %r{/(.+)/raw/([^/]+)/(.+)$} do |repo_name, reference, path|
         @blob = blob_for repo_name, reference, path
         if @blob.binary?
            headers 'Content-Disposition' =>
                     "attachment; filename=\"#{@blob.basename}\"",
               'Content-Transfer-Encoding' => 'application/octet-stream',
               'Content-Transfer-Encoding' => 'binary'
         else
             headers 'Content-Transfer-Encoding' => 'text/plain'
         end
         @blob.data
      end

      get %r{/(.+)/commits/?$} do |repo_name|
         commits repo_name
      end

      get %r{/(.+)/commits/([^/]+)?$} do |repo_name, branch|
         commits repo_name, branch
      end
   end
end

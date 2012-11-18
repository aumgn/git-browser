require 'sinatra/base'
require 'mustache/sinatra'

require './lib/repository_browser'
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

         def tree(*args)
            @repobrowser = RepositoryBrowser.new(*args)
            @repobrowser.tree
         rescue RepositoryBrowser::Error
            raise Sinatra::NotFound
         end

         def blob(*args)
            @repobrowser = RepositoryBrowser.new(*args)
            @repobrowser.blob
         rescue RepositoryBrowser::Error
            raise Sinatra::NotFound
         end

         def commits(*args)
            @repobrowser = RepositoryBrowser.new(*args)
            @repobrowser.commits(params[:page] || 0)
         rescue RepositoryBrowser::Error
            raise Sinatra::NotFound
         end

         def stats(repo_name)
            @repobrowser = RepositoryBrowser.new(repo_name)
            nil
         rescue RepositoryBrowser::Error
            raise Sinatra::NotFound
         end
      end

      get '/' do
         @repositories = Repositories.map.to_a
         mustache :index
      end

      optional_branch_and_path = '(?:/([^/]+)(?:/(.+?))?)?/?$'
      get %r{/(.+)/tree#{optional_branch_and_path}} do |*args|
         @tree = tree *args
         mustache :tree
      end

      get %r{/(.+)/blob/([^/]+)/(.+)$} do |*args|
         @blob = blob *args
         mustache :blob
      end

      get %r{/(.+)/raw/([^/]+)/(.+)$} do |*args|
         @blob = blob *args

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

      get %r{/(.+)/blame/([^/]+)/(.+)$} do |*args|
         @blob = blob *args
         @blame = @repobrowser.blame
         mustache :blame
      end

      get %r{/(.+)/commits#{optional_branch_and_path}} do |*args|
         @commits = commits *args
         mustache :commits
      end

      get %r{/(.+)/commit/([a-f0-9^]+)/?$} do |repo_name, commit_id|
         raise Sinatra::NotFound unless Repositories.exists? repo_name
         @repo = Repositories.get repo_name

         @commit = @repo.commit commit_id
         raise Sinatra::NotFound if @commit.nil?

         mustache :commit
      end

      get %r{/(.+)/stats/?$} do |repo_name|
         stats repo_name
         mustache :stats
      end
   end
end

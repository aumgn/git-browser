require './app/env'
require 'sinatra/base'
require 'mustache/sinatra'

module GitBrowser

   class App < Sinatra::Base
      set :environment, GitBrowser::Env
      set :root, GitBrowser::Root

      register Mustache::Sinatra
      set :mustache, {
         :views => './views/',
         :templates => 'templates/'
      }
      require './views/layout'
      Dir['./views/layout/*.rb'].each { |view| require view }

      get '/' do
         @repositories = Repositories.map.to_a
         mustache :index
      end

      optional_branch_and_path = '(?:/([^/]+)(?:/(.+?))?)?/?$'
      get %r{/(.+)/tree#{optional_branch_and_path}} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @tree = @repobrowser.tree
         mustache :tree
      end

      get %r{/(.+)/blob/([^/]+)/(.+)$} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @blob = @repobrowser.blob
         redirect @repobrowser.url('raw') if @blob.binary?
         mustache :blob
      end

      get %r{/(.+)/raw/([^/]+)/(.+)$} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @blob = @repobrowser.blob

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
         @repobrowser = RepositoryBrowser.new(*args)
         @blob = @repobrowser.blob
         @blame = @repobrowser.blame
         mustache :blame
      end

      get %r{/(.+)/commits#{optional_branch_and_path}} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @commitspager = @repobrowser.commits_pager(params[:page].to_i || 0)
         mustache :commits, layout: !request.xhr?
      end

      get %r{/(.+)/commit/([a-f0-9^]+)/?$} do |repo_name, commit_id|
         @repobrowser = RepositoryBrowser.new repo_name, commit_id
         @commit = @repobrowser.commit
         mustache :commit
      end

      get %r{/(.+)/stats/?$} do |repo_name|
         @repobrowser = RepositoryBrowser.new(repo_name)
         mustache :stats
      end

      get %r{/(.+)/(tar(?:gz)?)ball(?:/([^/]+))?/?} do |repo_name, format, reference = nil|
         begin
            repobrowser = RepositoryBrowser.new(repo_name, reference)
         rescue RepositoryBrowser::Error
            raise Sinatra::NotFound
         end
         ctype = format == 'tar' ? 'application/x-tar' : 'application/x-tgz'
         filename = File.basename(repobrowser.repository_name)
         filename << '-' << repobrowser.reference
         filename << '.' << (format == 'tar' ? 'tar' : 'tar.gz')
         headers 'Content-type' => ctype,
               'Content-Description' => 'File Transfer',
               'Content-Disposition' => "attachment; filename=\"#{filename}\"",
               'Content-Transfer-Encoding' => 'binary'
         repobrowser.archive format
      end

      error Sinatra::NotFound do
         @message = "Not found !"
         mustache :error
      end

      error RepositoryBrowser::Error do
         @message = env['sinatra.error'].message
         status 404
         mustache :error
      end

      error do
         @message = "An internal error occured :sad:"
         mustache :error
      end
   end
end

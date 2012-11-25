require_relative 'env'
require 'sinatra/base'
require 'mustache/sinatra'

module GitBrowser

   class App < Sinatra::Base
      set :environment, GitBrowser::Env
      set :root, GitBrowser::Root

      GitBrowser.development? do
         require 'sinatra/reloader'
         register Sinatra::Reloader
         also_reload "app/**/*"
         also_reload "views/*"
      end

      register Mustache::Sinatra
      set :mustache, {
         :views => './views/',
         :templates => 'templates/'
      }

      require './views/layout'
      require './views/project_layout'
      Dir['./views/*.rb'].each { |view| require view }

      get '/' do
         @repositories = Repositories.map.to_a
         mustache :index
      end

      optional_branch_and_path = '(?:/([^/]+)(?:/(.+?))?)?/?$'
      get %r{/(.+)/tree#{optional_branch_and_path}} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @tree = @repobrowser.tree_blob
         redirect @repobrowser.url 'blob' if @tree.blob?
         mustache :tree
      end

      get %r{/(.+)/blob/([^/]+)/(.+)$} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @blob = @repobrowser.tree_blob
         redirect @repobrowser.url 'tree' if @blob.tree?
         redirect @repobrowser.url 'raw' if @blob.binary?
         mustache :blob
      end

      get %r{/(.+)/raw/([^/]+)/(.+)$} do |*args|
         @repobrowser = RepositoryBrowser.new(*args)
         @blob = @repobrowser.tree_blob
         redirect @repobrowser.url 'tree' if @blob.tree?
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
         @blob = @repobrowser.tree_blob
         redirect @repobrowser.url 'tree' if @blob.tree?
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

      formats = Backend::Repository.archive_formats.keys * '|'
      archive = %r{/(.+)/(#{formats})ball(?:/([^/]+))?/?}
      get archive do |repo_name, format_name, reference = nil|
         begin
            repobrowser = RepositoryBrowser.new(repo_name, reference)
         rescue RepositoryBrowser::Error
            raise Sinatra::NotFound
         end
         format = Backend::Repository.archive_formats[format_name]
         filename = File.basename(repobrowser.repo.name)
         filename << '-' << repobrowser.reference << '.' << format.extension
         headers 'Content-type' => format.mime_type,
               'Content-Description' => 'File Transfer',
               'Content-Disposition' => "attachment; filename=\"#{filename}\"",
               'Content-Transfer-Encoding' => 'binary'
         repobrowser.archive format_name
      end

      error Sinatra::NotFound do
         mustache :error, locals: {
            message: "Not found !"
         }
      end

      error RepositoryBrowser::Error do
         status 404
         mustache :error, locals: {
            message: env['sinatra.error'].message
         }
      end

      error do
         mustache :error, locals: {
            message: "An internal error occured :sad:"
         }
      end
   end
end

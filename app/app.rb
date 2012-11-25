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

      def self.repository_get(path, &block)
         method = send(:generate_method, "repository_get #{path}", &block)
         get path do |*args|
            begin
               @repobrowser = RepositoryBrowser.new(*args)
               method.bind(self).call
            rescue RepositoryBrowser::Error => exc
               halt 404, exc.message
            end
         end
      end

      get '/' do
         @repositories = Repositories.map.to_a
         mustache :index
      end

      optional_branch_and_path = '(?:/([^/]+)(?:/(.+?))?)?/?$'
      repository_get %r{/(.+)/tree#{optional_branch_and_path}} do
         @tree = @repobrowser.tree_blob
         redirect @repobrowser.url 'blob' if @tree.blob?
         mustache :tree
      end

      repository_get %r{/(.+)/blob/([^/]+)/(.+)$} do
         @blob = @repobrowser.tree_blob
         redirect @repobrowser.url 'tree' if @blob.tree?
         redirect @repobrowser.url 'raw' if @blob.binary?
         mustache :blob
      end

      repository_get %r{/(.+)/raw/([^/]+)/(.+)$} do
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

      repository_get %r{/(.+)/blame/([^/]+)/(.+)$} do
         @blob = @repobrowser.tree_blob
         redirect @repobrowser.url 'tree' if @blob.tree?
         @blame = @repobrowser.blame
         mustache :blame
      end

      repository_get %r{/(.+)/commits#{optional_branch_and_path}} do
         @commitspager = @repobrowser.commits_pager(params[:page].to_i || 0)
         mustache :commits, layout: !request.xhr?
      end

      repository_get %r{/(.+)/commit/([a-f0-9^]+)/?$} do
         @commit = @repobrowser.commit
         mustache :commit
      end

      formats = Backend::Repository.archive_formats.keys * '|'
      archive = %r{/(.+)/(#{formats})ball(?:/([^/]+))?/?}
      get archive do |repo_name, format_name, reference = nil|
         begin
            repobrowser = RepositoryBrowser.new(repo_name, reference)
         rescue RepositoryBrowser::Error => exc
            halt 404, exc.message
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

      repository_get %r{/(.+)/?$} do
         redirect @repobrowser.url 'tree', reference: nil
      end

      not_found do
         if response.body.nil? or response.body.empty?
            @message = "Not found !"
         else
            @message = response.body.first
         end
         mustache :error
      end

      error do
         @message = "An internal error occured :sad:"
         mustache :error
      end
   end
end

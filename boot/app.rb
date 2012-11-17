require 'sinatra/base'

module GitBrowser

   class App < Sinatra::Base
      set :environment, GitBrowser::Env
      set :root, GitBrowser::Root

      get '/' do
         @repositories = [
            Repository.new('test', 'test', 'Test repository'),
            Repository.new('test2', 'test2', 'Test2 repository')
         ]
         erb :index
      end
   end

   Repository = Struct.new(:name, :path, :description)
end

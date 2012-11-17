require 'sinatra/base'

module GitBrowser

   class App < Sinatra::Base
      set :environment, GitBrowser::Env
      set :root, GitBrowser::Root

      get '/' do
         @repositories = Repositories.map.to_a
         erb :index
      end
   end
end

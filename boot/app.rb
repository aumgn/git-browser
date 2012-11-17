require 'sinatra/base'

module GitBrowser

   class App < Sinatra::Base
      set :environment, GitBrowser::Env
      set :root, GitBrowser::Root

      get '/' do
         erb :layout
      end
   end
end

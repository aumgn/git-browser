Encoding.default_internal = "UTF-8"
Encoding.default_external = "UTF-8"

module GitBrowser

   extend self

   Env = (::ENV["RACK_ENV"] || "development").to_sym
   Root = File.expand_path('../..', __FILE__)

   def path(*args)
      File.join(Root, *args)
   end

   def glob(*args)
      Dir[path(*args)]
   end

   def development?(&block)
      env :development, &block
   end

   def production?(&block)
      env :production, &block
   end

   def test?(&block)
      env :test, &block
   end

   def env(name)
      bool = name == Env
      yield if bool and block_given?
      bool
   end

   require 'yaml'
   Config = YAML.load_file path('app', 'conf', 'config.yml')

   require 'bundler'
   backend = Config['backend'].to_sym
   Bundler.setup(:default, Env, backend)

   require_relative 'lib/file_types'
   require_relative 'backend/init'
   require_relative 'lib/repositories_list'
   Repositories = RepositoriesList.new(Config['repositories'],
      Config['hidden'])

   require_relative 'lib/repository_browser'
end

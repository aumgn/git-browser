Encoding.default_internal = "UTF-8"
Encoding.default_external = "UTF-8"

module GitBrowser

   Env = (::ENV["RACK_ENV"] || "development").to_sym
   Root = File.expand_path('../..', __FILE__)

   class << self

      def path(*args)
         File.join(Root, *args)
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

   private

      def env(name)
         bool = name == Env
         if bool and block_given?
            yield
         end
         bool
      end
   end

   require 'bundler'
   Bundler.setup(:default, Env)

   require 'yaml'
   Config = YAML.load_file path('boot', 'config.yml')
end

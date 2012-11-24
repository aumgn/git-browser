require 'yaml'

module GitBrowser

   class YamlConfig

      attr_reader :repositories, :hidden, :commits_per_page, :backend

      def initialize(file)
         abort "Config file \"#{file}\" not found" unless File.exists? file
         yaml = YAML.load_file file
         read_yaml yaml
      rescue Psych::SyntaxError => exc
         abort "YAML syntax error : #{exc.message}"
      rescue Psych::Exception
         abort "An error occured while parsing config.yml"
      end

   private

      def read_yaml(yaml)
         unless yaml.has_key? 'repositories'
            abort 'Missing "repositories" option in config file'
         end
         @repositories = yaml['repositories'].to_s

         @hidden = yaml['hidden']
         @hidden = [ @hidden ] unless @hidden.is_a? Array
         @hidden.compact!

         @commits_per_page = yaml['commits_per_page'].to_i
         if @commits_per_page < 1
            abort 'Invalid "commits_per_page" option. (Integer > 0 expected)'
         end

         @backend = yaml['backend']
         unless @backend.respond_to? :to_sym
            abort 'Invalid "backend" option'
         end
         @backend = @backend.to_sym
         unless [:grit, :rugged].include? @backend
            abort "Backend \"#{backend}\" does not exist"
         end
      end

      def abort(message)
         puts message
         Kernel.exit 1
      end
   end
end

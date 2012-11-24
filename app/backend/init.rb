module GitBrowser::Backend

   class BaseRepository

      attr_reader :name

      def initialize(name, path)
         @name = name
      end

      def display_name
         @name.gsub(/\.git$/, '')
      end

      def display_description
         if File.exists?(File.join(path, 'description'))
            description
         else
            'No description'
         end
      end
   end

   class ArchiveFormat < Struct.new(:extension, :mime_type)
   end

   class NoSuchRepository < RuntimeError

      def initialize(path)
         @path = path
      end

      def message
         "Repository at #{path} not found. #{super}"
      end
   end
end

require_relative "#{GitBrowser::Config.backend}/backend"

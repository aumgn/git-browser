require 'yaml'

module GitBrowser

   module FileTypes

      yaml = YAML.load_file GitBrowser.path('app', 'conf', 'filetypes.yml')

      FileTypesByName = yaml['by_filename']
      FileTypesByExtension = yaml['by_extension']

      def binary?
         filetype == 'binary'
      end

      def image?
         filetype == 'image'
      end

      def filetype
         @filetype ||= guess_filetype
      end

   private

      def guess_filetype
         by_extension || by_name || 'binary'
      end

      def by_extension
         FileTypesByExtension[File.extname(basename)[1..-1]]
      end

      def by_name
         FileTypesByName[basename]
      end
   end
end

class Grit::Blob

   include GitBrowser::FileTypes
end

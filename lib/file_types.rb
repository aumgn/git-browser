require 'linguist'

module GitBrowser

   module FileTypes

      include Linguist::BlobHelper

      BinaryTypes = [
        'exe', 'com', 'so', 'la', 'o', 'dll', 'pyc', 'jpg', 'jpeg', 'bmp',
        'gif', 'png', 'xmp', 'pcx', 'svgz', 'ttf', 'tiff', 'oet', 'gz', 'tar',
        'rar', 'zip', '7z', 'jar', 'class', 'odt', 'ods', 'pdf', 'doc', 'docx',
        'dot', 'xls', 'xlsx',
      ]

      ImageTypes = [ 'png', 'jpg', 'gif', 'jpeg', 'bmp' ]

      def binary?
         extension_in? BinaryTypes
      end

      def image?
         extension_in? ImageTypes
      end

   private

      def extension_in?(ary)
         ext = File.extname(basename)
         return false if ext.empty?
         ary.include? ext[1..-1]
      end
   end
end

class Grit::Blob

   include GitBrowser::FileTypes
end

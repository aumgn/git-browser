require 'fileutils'
require './app/env'

include GitBrowser

bootstrap_file = path('less', 'bootstrap.less')
less_files = glob('less', '*.less')
css_file = path('public', 'css', 'style.css')
file css_file => less_files do
   cmd = 'lessc'
   production? { cmd << ' --compress' }
   system "#{cmd} #{bootstrap_file} > #{css_file}"
end

task :style => css_file

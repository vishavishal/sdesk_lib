require 'sketchup.rb'
require 'extensions.rb'

folder_path = '/Users/vivek/SkpDesk/Current'
folder_path = '/Users/vivek/Desktop/sdesk_lib'

loader 			    = File.join(folder_path, 'skpdesk_loader.rb')
title 			    = 'SKP Design Kit'
ext 			      = SketchupExtension.new(title, loader)
ext.version 	  = '1.0.0'
ext.copyright 	= 'Skpdesk - 2020'
ext.creator 	  = 'Skpdesk.com'
Sketchup.register_extension(ext, true)

require 'rubygems'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'gems', 'oclc-auth-0.1.1', 'lib')))


my_routes = [File.join(File.dirname(__FILE__), "routes.rb")]
ArchivesSpace::Application.config.paths['config/routes'].concat(my_routes)

# auto reload api in development mode

# if Rails.env.development?
#   ArchivesSpace::Application.config.paths["app/models"].concat(
# end


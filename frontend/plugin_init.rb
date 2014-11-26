require 'rubygems'
require 'jsonmodel'
require 'jsonmodel_client'
require 'fileutils'


$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'gems', 'oclc-auth-0.1.1', 'lib')))
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'gems', 'rest-client-1.6.7', 'lib')))
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'gems', 'rufus-lru-1.0.5', 'lib')))


my_routes = [File.join(File.dirname(__FILE__), "routes.rb")]
ArchivesSpace::Application.config.paths['config/routes'].concat(my_routes)

FileUtils.mkdir_p(File.join(ASUtils.find_base_directory, 'logs'))

class OCLCLog

  @log_path = File.join(ASUtils.find_base_directory, 'logs', 'oclc.out')

  def self.log(something)
    File.open(@log_path, 'a') {|f| 
      f.write(something) 
      f.write("\n")
    }
  end
end

OCLCLog.log("OCLC Plugin Init")

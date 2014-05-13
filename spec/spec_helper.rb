require 'rspec'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'gems', 'oclc-auth-0.1.1', 'lib')))

def get_wscred
  YAML.load_file('wskey.yml')
end



require 'rubygems'
require 'puppet'
require 'rspec-puppet'

def param_value(subject, type, title, param)
  subject.resource(type, title).send(:parameters)[param.to_sym]
end

fixture_path = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end

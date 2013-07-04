require 'rake'
require 'puppet-lint/tasks/puppet-lint'

task :default => [:spec]

desc "Run all module spec tests (Requires rspec-puppet gem)"
task :spec do
  system("rspec spec/**/*_spec.rb")
end

desc "Build package"
task :build do
  system("puppet-module build")
end


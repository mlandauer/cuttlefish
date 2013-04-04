require "rvm/capistrano"
require 'bundler/capistrano'

set :application, "cuttlefish"
set :repository,  "git://github.com/mlandauer/cuttlefish.git"
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")

server "kedumba.openaustraliafoundation.org.au", :app, :web, :db, :primary => true

set :use_sudo, false
set :user, "deploy"
set :deploy_to, "/srv/www/cuttlefish.openaustraliafoundation.org.au"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
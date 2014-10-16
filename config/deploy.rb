require 'new_relic/recipes'
require "rvm/capistrano"
require 'bundler/capistrano'

# MUST EDIT
#
# Either fork the repository for edits and deployment
# or optionally create a new branch
# `git checkout -b production`
# and change the upstream url to a private repository
# `git remote add bitbucket git@bitbucket.org:USERNAME/REPO.git`
# `git push -u bitbucket production`
set :repository,  "git@bitbucket.org:USERNAME/REPO.git"
set :branch, "production"
server "YOURSERVER.COM", :app, :web, :db, primary: true
set :deploy_to, "/home/user/path/to/deploy"
set :user, "deploy"     # ssh username

# details about various parameters:
# https://github.com/capistrano/capistrano/wiki/2.x-Significant-Configuration-Variables

set :application, "cuttlefish"
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")

set :use_sudo, false
#set :deploy_via, :remote_cache

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
before "deploy:restart", "foreman:restart"
after "deploy:restart", "newrelic:notice_deployment"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "After a code update, we link additional config and data directories"
  before "deploy:assets:precompile" do
    links = {
      "#{release_path}/config/database.yml"                => "#{shared_path}/database.yml",
      "#{release_path}/config/environments/production.rb"  => "#{shared_path}/production.rb",
      "#{release_path}/config/newrelic.yml"                => "#{shared_path}/newrelic.yml",
      "#{release_path}/config/initializers/honeybadger.rb" => "#{shared_path}/honeybadger.rb",
      "#{release_path}/db/emails"                          => "#{shared_path}/emails",
      "#{release_path}/db/user_agents"                     => "#{shared_path}/user_agents",
    }
    # Copy across the example database configuration file if there isn't already one
    run "test -f #{shared_path}/database.yml || cp #{release_path}/config/database.yml #{shared_path}/database.yml"
    run "test -f #{shared_path}/production.rb || cp #{release_path}/config/environments/production.rb #{shared_path}/production.rb"
    run "test -d #{shared_path}/emails || mkdir -p #{shared_path}/emails"
    run "test -d #{shared_path}/user_agents || mkdir -p #{shared_path}/user_agents"
    # "ln -sf <a> <b>" creates a symbolic link but deletes <b> if it already exists
    run links.map {|a| "ln -sf #{a.last} #{a.first}"}.join(";")
  end

end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, roles: :app do
    run "cd #{current_path} && rvmsudo bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{shared_path}/log -f Procfile.production"
  end

  desc "Start the application services"
  task :start, roles: :app do
    sudo "service #{application} start"
  end

  desc "Stop the application services"
  task :stop, roles: :app do
    sudo "service #{application} stop"
  end

  desc "Restart the application services"
  task :restart, roles: :app do
    run "sudo service #{application} restart"
  end
end

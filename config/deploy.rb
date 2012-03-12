require "bundler/capistrano"
require "capistrano/ext/multistage"

$:.unshift File.expand_path( "./lib" , ENV[ "rvm_path" ] )
require "rvm/capistrano"


set :application                , CONFIG.deploy_application
set :default_run_options        , :pty => true
set :deploy_via                 , :remote_cache
set :normalize_asset_timestamps , false
set :repository                 , CONFIG.deploy_repository
set :rvm_ruby_string            , CONFIG.app_ruby
set :scm                        , :git
set :use_sudo                   , true

ssh_options[ :forward_agent ] = true

load "config/deploy/support/stages"
load "config/deploy/support/default_stage"

namespace :deploy do
  task :create_deploy_to_location , :roles => :app do
    sudo "mkdir -p #{ deploy_to }"
  end

  task :restart do
    foreman.restart
  end

  task :start do
    foreman.start
  end

  task :stop do
    foreman.stop
  end

  task :update_deploy_to_permissions , :roles => :app do
    sudo "chown -hR #{ user }:#{ user } #{ deploy_to }"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    environment_file = "#{ shared_path }/#{ app_env }.env"
    upstart_tmp_path = "#{ shared_path }/tmp/upstart"
    run <<COMMAND
mkdir -p #{ upstart_tmp_path } && \
rm -f #{ upstart_tmp_path }/*.conf && \
cd #{ current_path } && \
exe/foreman export upstart #{ upstart_tmp_path } \
  -a #{ application }-#{ app_env } \
  -e #{ environment_file } \
  -f Procfile \
  -l #{ shared_path }/log \
  -p #{ application_port } \
  -u #{ user } && \
sudo cp -f #{ upstart_tmp_path }/*.conf /etc/init
COMMAND
  end

  desc "Link the required Foreman .env file from shared"
  task :link_env_file , :roles => :app do
    shared_environment_file = "#{ shared_path }/#{ app_env }.env"
    run "ln -s #{ shared_environment_file } #{ release_path }/.env"
  end

  desc "Start the application services"
  task :start , :roles => :app do
    sudo "start #{ application }-#{ app_env }"
  end

  desc "Stop the application services"
  task :stop , :roles => :app do
    sudo "stop #{ application }-#{ app_env }"
  end

  desc "Restart the application services"
  task :restart , :roles => :app do
    run "sudo restart #{ application }-#{ app_env }"
  end
end

namespace :rvm do
  desc "Auto trust the app RVMRC file"
  task :trust_rvmrc , :roles => :app do
    run "rvm rvmrc trust #{ release_path }"
  end
end

before "deploy:setup"  , "deploy:create_deploy_to_location"

after  "deploy"        , "rvm:trust_rvmrc"
after  "deploy:setup"  , "deploy:update_deploy_to_permissions"
after  "deploy:update" , "foreman:link_env_file"
after  "deploy:update" , "foreman:export"

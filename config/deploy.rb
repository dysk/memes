# coding: UTF-8

#require 'capistrano_colors'
require 'bundler/capistrano'

set :default_env,  'production'
set :rails_env,     ENV['rails_env'] || ENV['RAILS_ENV'] || default_env

set :user, "espago-mems"
set :runner, user
set :application, user

set :repository,  "espago@git.espago.com:espago-memes.git"
set :domain, "espago-mems"

role :app, '109.205.48.248'
role :web, '109.205.48.248'
role :db, '109.205.48.248', :primary=>true

#set :branch, "master"
set :rails_env,  'production'
set :applicationdir, "/home/espago-mems/www"

set :scm, :git
set :scm_verbose, false

set (:deploy_to) {"#{applicationdir}"}

set :deploy_via, :remote_cache
set :deploy_env, 'production'

set :local_repository, repository
set :branch, "master"

set :use_sudo, false
set :sudo, 'sudo'
set :sudo_prompt, ''

set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
default_run_options[:shell] = false

###############################################################################
# Custom Tasks
###############################################################################

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true }  do
    run "#{try_sudo} /etc/init.d/unicorn start espago-mems"
  end
  task :stop, :roles => :app, :except => { :no_release => true }  do
    run "#{try_sudo} /etc/init.d/unicorn stop espago-mems"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} /etc/init.d/unicorn  restart espago-mems"
  end
end

namespace :symlink do
  desc "Create a symlink to database.yml"
  task :database, :roles => :app do
    run "ln -fs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    set :bundle_dir, File.join(release_path, 'vendor', 'bundle')
    shared_dir = File.join(shared_path, 'bundle')
    run "rm -rf #{bundle_dir}"
    run "mkdir -p #{shared_dir} && ln -s #{shared_dir} #{bundle_dir}"
  end
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} ; bundle install --deployment --without development test"
  end
end

namespace :assets do
  task :precompile, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:clean"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end
end


#############################################################
# After deploy
#############################################################

after "deploy:create_symlink", "symlink:database"
after "deploy:create_symlink", "bundler:bundle_new_release"
after "deploy:create_symlink", "assets:precompile"


#load 'deploy/assets'


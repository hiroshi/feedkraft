$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano" # Load RVM's capistrano plugin.
require 'bundler/capistrano'

set :application, "feedkraft"
set :repository,  "git://github.com/hiroshi/feedkraft.git"
set :branch, "ruby19_rails3"
set :scm, :git
set :deploy_via, :remote_cache

# USAGE: Use this task like:
#   cap feedkraft.yakitara.com deploy
desc "set target feedkraft.com"
task "feedkraft.com" do
  set :target, task_call_frames.first.task.name
  server "silent.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/feedkraft"
  set :user, "www-data"
  set :group, "www-data"
  set :use_sudo, false
end

desc "set target feedkraft.yakitara.com"
task "feedkraft.yakitara.com" do
  set :target, task_call_frames.first.task.name
  server "jerle.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/feedkraft"
  set :user, "www-data"
  set :group, "www-data"
  set :use_sudo, false
end

desc "copy target initializers"
task :copy_initializers do
  run "cp #{latest_release}/config/deploy/#{target}/initializers/*.rb #{latest_release}/config/initializers/ || exit 0"
  run "cp #{shared_path}/config/initializers/*.rb #{latest_release}/config/initializers/ || exit 0"
end
after "deploy:update_code", "copy_initializers"

namespace :deploy do
  desc "change group of setuped directory"
  task :setup_change_group do
    run "chown -R :#{group} #{deploy_to}"
  end
  after "deploy:setup", "deploy:setup_change_group"

  desc "change group of deployed directory"
  task :change_group do
    run "chown -R :#{group} #{latest_release}"
  end
  after "deploy:finalize_update", "deploy:change_group"
end

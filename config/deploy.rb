set :application, "feedkraft"
set :repository,  "git://github.com/hiroshi/feedkraft.git"
set :scm, :git
set :deploy_via, :remote_cache

# USAGE: Use this task like:
#   cap feedkraft.yakitara.com deploy
desc "set target feedkraft.yakitara.com"
task "" do
  set :target, task_call_frames.first.task.name
  server "silent.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/feedkraft"
  set :user, "www-data"
  set :use_sudo, false
end

desc "copy target initializers"
task :copy_initializers do
  run "cp #{latest_release}/config/deploy/#{target}/initializers/*.rb #{latest_release}/config/initializers/ || exit 0"
end
after "deploy:update_code", "copy_initializers"

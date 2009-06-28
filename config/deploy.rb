set :application, "feedkraft"
#set :repository,  "hiroshi@silent.yakitara.com:/var/git/feedkraft.git"
set :repository,  "git://github.com/hiroshi/feedkraft.git"
set :deploy_to, "/var/www/feedkraft"
set :scm, :git
set :deploy_via, :remote_cache

server "silent.yakitara.com", :app, :web, :db, :primary => true
set :user, "www-data"
set :use_sudo, false

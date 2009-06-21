set :application, "pursuer"
set :repository,  "hiroshi@silent.yakitara.com:/var/git/pursuer.git"
set :deploy_to, "/var/www/pursuer"
set :scm, :git
set :deploy_via, :remote_cache

server "silent.yakitara.com", :app, :web, :db, :primary => true
set :user, "www-data"
set :use_sudo, false

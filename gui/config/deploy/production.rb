# For migrations
set :rails_env, 'production'

set :scm, "git"
set :branch, "master"

# Who are we?
set :application, 'fax'
set :repository,  "git@github.com:#{application}"
set :scm, "git"
#set :deploy_via, :remote_cache
set :branch, "master"
set :migrate_path, "/gui/"

# Where to deploy to?
role :web, "prod-server"
role :app, "prod-server"
role :db,  "prod-server", :primary => true

# Deploy details
set :user, 'root'
set :deploy_to, "/var/rails/#{application}"
set :use_sudo, false
set :checkout, 'export'
#set :public_children, 
set :normalize_asset_timestamps, false
# We need to know how to use mongrel
# set :mongrel_rails, '/usr/local/bin/mongrel_rails'
# set :mongrel_cluster_config, "#{deploy_to}/#{current_dir}/config/mongrel_cluster_production.yml"
after "deploy:update_code", "deploy:chown", "deploy:ahn_env", "deploy:bundler_rails"

# namespace :deploy do
# 
#   desc 'Restart the application servers.'
#   task :restart, :except => { :no_release => true } do
#    deploy.stop
#    deploy.start
#   end
# end

namespace :deploy do
  desc 'Start the application servers.'
  task :start do
    run "god start fax" # -p #{god_port}
  end

  desc 'Stop the application servers.'
  task :stop do
    run "god stop fax" # -p #{god_port}
  end

  desc "Change owner"
  task :chown, :roles => :app do
    run "touch #{latest_release}/gui/audit.log"
    run "chmod 755 #{latest_release}/mail_processor.sh"
    run "rm -rf #{latest_release}/gui/log && ln -s /var/rails/fax/shared/log #{latest_release}/gui/log"
    run "rm -rf #{latest_release}/gui/public/system/ && ln -s /var/rails/fax/shared/system #{latest_release}/gui/public/system"
    run "chown www-data:www-data -R #{latest_release}"
  end
  
  desc "Replace environment for Adhearsion"
  task :ahn_env, :roles => :app do
    run "cat #{latest_release}/config/startup.rb | sed -e s/\"config.enable_rails :path => 'gui', :env => :development\"/\"config.enable_rails :path => 'gui', :env => :production\"/g > #{latest_release}/config/startup.rb"
  end
  
  desc "Installing Rails Bundle"
  task :bundler_rails do
    run "cd #{latest_release}/gui/ && rm -f Gemfile && ln -s ../Gemfile"
    run "cd #{latest_release}/gui/ && rm -f Gemfile.lock && ln -s ../Gemfile.lock"
    run "cd #{latest_release}/gui/ && bundle install --gemfile Gemfile --path  /var/rails/#{application}/shared/bundle  --deployment --quiet --without development test"
  end

  desc 'Restart the application servers.'
  task :restart, :except => { :no_release => true } do
    run "mkdir #{current_path}/gui/tmp"
    run "touch #{current_path}/gui/tmp/restart.txt"
    #god_config = "#{current_path}/gui/config/god/fax.god"

    # Stop god without terminating adhearsion
    run "god quit"

    # Start god to make sure we've reloaded the latest
    # god config
    run "god -c /etc/god/god.conf -l /var/log/god.log --log-level error"

    # Send adhearsion a signal to nicely quit -- 
    # it will automatically restart
    # wait for god to start
    sleep 2
    run "god signal #{application} TERM"
  end
end
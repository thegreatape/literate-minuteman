#---
# Excerpted from "Agile Web Development with Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rails4 for more book information.
#---
# be sure to change these
set :user, 'tmayfield'
set :domain, 'zen-hacking.com'
set :application, 'literate-minuteman'

# adjust if you are using RVM, remove if you are not
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
#require "rvm/capistrano"
#set :rvm_ruby_string, '1.9.2'
#set :rvm_type, :user

# file paths
set :repository,  "git@github.com:thegreatape/#{application}.git" 
set :deploy_to, "/var/www/#{application}" 

# distribute your applications across servers (the instructions below put them
# all on the same server, defined above as 'domain', adjust as necessary)
role :app, domain
role :web, domain
role :db, domain, :primary => true

# you might need to set this if you aren't seeing password prompts
# default_run_options[:pty] = true

# As Capistrano executes in a non-interactive mode and therefore doesn't cause
# any of your shell profile scripts to be run, the following might be needed
# if (for example) you have locally installed gems or applications.  Note:
# this needs to contain the full values for the variables set, not simply
# the deltas.
# default_environment['PATH']='<your paths>:/usr/local/bin:/usr/bin:/bin'
# default_environment['GEM_PATH']='<your paths>:/usr/lib/ruby/gems/1.8'

# miscellaneous options
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, :production
set :normalize_asset_timestamps, false

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
end

after "deploy:update_code", :update_config
desc "copy prod db config and goodreads keys to deployment"
task :update_config, :roles => :app do
  run "cd #{release_path} && cp /var/www/literate-minuteman-database.yml #{release_path}/config/database.yml"
  run "cd #{release_path} && cp /var/www/goodreads.rb #{release_path}/config/initializers/goodreads.rb"
end

after "deploy:update_code", :bundle_install
desc "install the necessary prerequisites"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"
end

after "bundle_install", :precompile_assets
desc "precompile assets"
task :precompile_assets, :roles => :app do
  run "cd #{release_path} && bundle exec rake assets:precompile"
end

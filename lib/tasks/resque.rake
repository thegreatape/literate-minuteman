require 'resque/tasks'
require 'resque_scheduler/tasks'    


namespace :resque do
  task :setup => :environment do
    ENV['QUEUE'] = '*'
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'      
    Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
    Resque.schedule = YAML.load_file("#{Rails.root}/config/resque-schedule.yml")
  end
end



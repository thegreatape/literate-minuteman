require 'lookup'
require 'resque/tasks'
require 'resque_scheduler/tasks'    

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'      

    Resque.schedule = YAML.load_file('resque-schedule.yml')
  end
end



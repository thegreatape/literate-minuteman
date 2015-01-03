task clear_resque_workers: :environment do
  Resque.workers.each {|w| w.unregister_worker}
end

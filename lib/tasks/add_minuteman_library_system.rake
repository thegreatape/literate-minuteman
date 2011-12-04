namespace :searchbots do
  task :add_minuteman => :environment do
    LibrarySystem.create!(:search_bot_class => "SearchBots::MinutemanBot",
                          :name => "Massachusetts Minuteman Library Network")
  end
end

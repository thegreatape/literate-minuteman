Factory.sequence :system_name do |n|
  "system #{n}"
end
Factory.define :library_system do |f|
  f.name             {Factory.next(:system_name)} 
  f.search_bot_class "SearchBots::MinutemanBot"
end

FactoryGirl.define do 
  factory :location do |f|
    library_system_id LibrarySystem::MINUTEMAN.id
    sequence(:name)  {|n| "location #{n}"} 
  end
end

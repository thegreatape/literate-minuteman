FactoryGirl.define do
  factory :user do |f|
    sequence(:goodreads_id) {|i| i.to_s }
    library_system_ids { [LibrarySystem::MINUTEMAN.id] }
  end
end

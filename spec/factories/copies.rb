FactoryGirl.define do
  factory :copy do |f|
    location
    f.status      "In"
    book
  end
end

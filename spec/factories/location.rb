Factory.sequence :location_name do |n|
  "location #{n}"
end
Factory.define :location do |f|
  f.association :library_system
  f.name        {Factory.next(:location_name)}
end

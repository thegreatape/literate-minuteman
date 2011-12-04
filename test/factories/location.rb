Factory.define :location do |f|
  f.association :library_system
  f.name        'location name'
end

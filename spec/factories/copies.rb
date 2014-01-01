Factory.define :copy do |f|
  f.association :location
  f.status      "In"
  f.association :book
end

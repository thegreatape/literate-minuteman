Factory.define :copy do |f|
  f.location    "location name"
  f.status      "In"
  f.association :book
end

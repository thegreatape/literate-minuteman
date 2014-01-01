Factory.define :book do |f|
  f.title "book title"
  f.author "book author"
  f.association :user
end

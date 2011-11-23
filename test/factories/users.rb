Factory.sequence :goodreads_id do |n|
  n
end
Factory.sequence :username do |n|
  "user#{n}"
end

Factory.define :user do |f|
  f.username     {Factory.next(:username)}
  f.password     'password'
  f.goodreads_id {Factory.next(:goodreads_id)}
end

Factory.sequence :goodreads_id do |n|
  n.to_s
end
Factory.sequence :email do |n|
  "user#{n}@test.com"
end

Factory.define :user do |f|
  f.email     {Factory.next(:email)}
  f.password     'password'
  f.goodreads_id {Factory.next(:goodreads_id)}
  f.library_systems { [Factory(:library_system)] }
end

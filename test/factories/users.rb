Factory.sequence :goodreads_id do |n|
  n.to_s
end

Factory.define :user do |f|
  f.goodreads_id {Factory.next(:goodreads_id)}
  f.library_systems { [Factory(:library_system)] }
end

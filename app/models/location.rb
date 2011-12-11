class Location < ActiveRecord::Base
  has_many :copies
  belongs_to :library_system
  has_and_belongs_to_many :users
  validates_presence_of :library_system_id

  default_scope :order => 'name ASC'
end

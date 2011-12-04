class Location < ActiveRecord::Base
  has_many :copies
  belongs_to :library_system
  validates_presence_of :library_system_id
end

class Location < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_many :copies
  belongs_to_active_hash :library_system

  has_and_belongs_to_many :users
  validates_presence_of :library_system_id
end

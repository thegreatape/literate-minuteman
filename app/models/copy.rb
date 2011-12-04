class Copy < ActiveRecord::Base
  belongs_to :book
  belongs_to :location
  validates_presence_of :book, :status, :location_id

  scope :for_library_system, lambda{|system|
    joins(:location).where(:locations => {:library_system_id => system.id})
  }
end

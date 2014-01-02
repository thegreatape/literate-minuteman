class Copy < ActiveRecord::Base
  belongs_to :book
  belongs_to :location
  validates_presence_of :book, :status, :location_id

  def self.for_library_system(system)
    joins(:location).where(:locations => {:library_system_id => system.id}).readonly(false)
  end

  def self.at_location(locations)
    where("location_id in (?)", Array(locations))
  end
end

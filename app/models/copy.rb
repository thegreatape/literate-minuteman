class Copy < ActiveRecord::Base
  belongs_to :book
  validates_presence_of :book
  validates_presence_of :status
end

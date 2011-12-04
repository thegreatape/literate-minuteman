class ChangeCopyLocationToLocationId < ActiveRecord::Migration
  def change
    remove_column :copies, :location
    add_column    :copies, :location_id, :integer
  end
end

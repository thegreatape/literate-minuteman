module UsersHelper
  def system_locations_columns(system)
    slice_size = [1, system.locations.length / 3].max
    system.locations.sort_by(&:name).each_slice(slice_size)
  end
end

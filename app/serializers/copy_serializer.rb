class CopySerializer < ActiveModel::Serializer
  attributes :title, :author, :call_number, :status, :last_synced_at, :location_name, :url

  def location_name
    object.location.name
  end
end

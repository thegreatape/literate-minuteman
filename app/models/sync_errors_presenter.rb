class SyncErrorsPresenter
  def library_systems
    @library_systems ||= Book.pluck('distinct json_object_keys(sync_errors)').map do |id|
      LibrarySystem.find(id)
    end
  end

  def [](library_system)
    Book.where("sync_errors->>? <> ''", library_system.id)
  end
end

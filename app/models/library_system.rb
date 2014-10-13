class LibrarySystem < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 'minuteman',
      name: "Massachusetts Minuteman Library Network",
      lookup_strategy: LookupStrategies::Minuteman },
    { id: 'boston',
      name: "Boston Public Library System",
      lookup_strategy: LookupStrategies::Boston },
    { id: 'boston-overdrive',
      name: "Boston Public Library - Overdrive Ebooks",
      lookup_strategy: LookupStrategies::BplOverdrive },
    { id: 'minuteman-overdrive',
      name: "Minuteman - Overdrive Ebooks",
      lookup_strategy: LookupStrategies::MinutemanOverdrive }
  ]

  enum_accessor :id

  def locations
    Location.where(library_system_id: id)
  end

  def find(title, author)
    lookup_strategy.new(title, author).find
  end
end

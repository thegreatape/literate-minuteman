@LocationStore = Fluxxor.createStore
  initialize: (locations, preferredLocations) ->
    @locations = Minuteman.locations
    @preferredLocations = Minuteman.preferredLocations

  getState: -> {
    locations: @preferredLocations
  }

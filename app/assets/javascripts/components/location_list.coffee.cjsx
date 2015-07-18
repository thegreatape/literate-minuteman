@LocationList = React.createClass
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("LocationStore")]

  getStateFromFlux: ->
    @getFlux().store("LocationStore").getState()

  render: ->
    <div className="select">
      <label>
        Show books at:
        <select className="form-control">
          <option value=''> All locations</option>
          {<option key={"location-#{location.id}"} value={location.id}>{location.name}</option> for location in @state.locations}
        </select>
      </label>
    </div>

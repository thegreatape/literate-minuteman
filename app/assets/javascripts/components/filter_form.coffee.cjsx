@FilterForm = React.createClass
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("LocationStore")]

  getStateFromFlux: ->
    @getFlux().store("LocationStore").getState()

  render: ->
    <form>
      Filter Results

      <div className="checkbox">
        <label>
          <input type="checkbox"/>
          Only show available copies
        </label>
      </div>

      <div className="checkbox">
        <label>
          <input type="checkbox"/>
          Only books with copies at my preferred locations
        </label>
      </div>

      <div className="select">
        <label>
          Show books at:
          <select className="form-control">
            <option value=''> All locations</option>
            {<option key={"location-#{location.id}"} value={location.id}>{location.name}</option> for location in @state.locations}
          </select>
        </label>
      </div>
    </form>

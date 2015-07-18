@AvailableCopiesToggle = React.createClass
  mixins: [Fluxxor.FluxMixin(React)]
  render: ->
    <div className="checkbox">
      <label>
        <input type="checkbox"/>
        Only show available copies
      </label>
    </div>

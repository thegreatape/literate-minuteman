@PreferredLocationToggle = React.createClass
  mixins: [Fluxxor.FluxMixin(React)]
  render: ->
    <div className="checkbox">
      <label>
        <input type="checkbox"/>
        Only books with copies at my preferred locations
      </label>
    </div>

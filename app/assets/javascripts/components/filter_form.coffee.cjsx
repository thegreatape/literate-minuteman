@FilterForm = React.createClass
  mixins: [Fluxxor.FluxMixin(React)]

  render: ->
    <form>
      Filter Results
      <AvailableCopiesToggle flux={@getFlux()} />
      <PreferredLocationToggle flux={@getFlux()} />
      <LocationList flux={@getFlux()} />
    </form>

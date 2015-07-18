@BookList = React.createClass
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("BookStore")]

  getStateFromFlux: ->
    @getFlux().store("BookStore").getState()

  render: ->
    <div id="book-list">
      { <Book key={book.id} book={book} /> for book in @state.books }
    </div>

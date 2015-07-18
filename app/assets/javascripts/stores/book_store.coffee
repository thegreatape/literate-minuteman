@BookStore = Fluxxor.createStore
  initialize: ->
    @books = []
    @bindActions(
      constants.LOAD_BOOKS, @loadBooks
      constants.LOAD_BOOKS_SUCCESS, @onLoadSuccess
    )

  loadBooks: ->
    $.ajax
      url: "/books.json",
      success: (response) =>
        @flux.actions.loadBooksSuccess(response)

  onLoadSuccess: (payload) ->
    @books = payload.books
    @emit('change')

  getState: -> {
    books: @books
  }

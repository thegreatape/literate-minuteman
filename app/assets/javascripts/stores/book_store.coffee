@BookStore = Fluxxor.createStore
  initialize: ->
    @books = []
    @bindActions(
      constants.LOAD_BOOKS, @loadBooks
      constants.LOAD_BOOKS_SUCCESS, @onBookLoadSuccess
    )

  loadBooks: ->
    $.ajax
      url: "/books.json",
      success: (response) =>
        @flux.actions.loadBooksSuccess(response)

  onBookLoadSuccess: (payload) ->
    @books = payload.books
    @emit('change')

  getState: -> {
    books: @books,
    pendingBookCount: 1
  }

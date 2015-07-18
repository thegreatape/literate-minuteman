#= require jquery
#= require moment
#= require underscore
#= require fluxxor
#= require react
#= require stores
#= require components
#= require react_ujs

@constants = {
  LOAD_BOOKS: "LOAD_BOOKS",
  LOAD_BOOKS_SUCCESS: "LOAD_BOOKS_SUCCESS",
  LOAD_BOOKS_FAILURE: "LOAD_BOOKS_FAILURE"
}

$ ->
  filterForm = $('#filter-form')[0]
  bookList = $('#book-list')[0]

  if filterForm && bookList

    stores = {
      LocationStore: new LocationStore(),
      BookStore: new BookStore()
    }

    actions = {
      loadBooks: -> @dispatch(constants.LOAD_BOOKS)
      loadBooksSuccess: (books) ->
        @dispatch(constants.LOAD_BOOKS_SUCCESS, {books: books})
    }

    flux = new Fluxxor.Flux(stores, actions)

    React.render(<FilterForm flux={flux} />, filterForm);
    React.render(<BookList flux={flux} />, bookList);

    flux.actions.loadBooks()

#= require jquery
#= require moment
#= require underscore
#= require fluxxor
#= require react
#= require stores
#= require components
#= require react_ujs

$ ->
  root = $('#filter-form')[0]
  if root
    stores = {
      LocationStore: new LocationStore()
    }
    actions = {

    }
    flux = new Fluxxor.Flux(stores, actions)
    React.render(<FilterForm flux={flux} />, root);

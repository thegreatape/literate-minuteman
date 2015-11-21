class UserForm
  constructor: (@$el) ->
    @$el.on 'change', '.available-systems input[type=checkbox]', @systemChanged

  systemChanged: (e) =>
    input = $(e.target)
    if input.is(':checked')
      @addSystem(input.val())
    else
      @removeSystem(input.val())
      sup

  addSystem: (id) =>
    $.ajax
      url: "/library_systems/#{id}"
      success: (html) =>
        @$el.find('.library-systems').prepend($(html))

  removeSystem: (id) =>
    $(".system-#{id}").remove()

@UserForm = UserForm

hi

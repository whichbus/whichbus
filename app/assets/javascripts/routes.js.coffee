class Bus.Routes extends Backbone.Router
  routes:
    '': 'index'

  initialize: ->
    @view = new Bus.Views.Application()
    $('#container').html(@view.render().el)

  index: ->

class Bus.Routes extends Backbone.Router
  routes:
    '': 'index'

  initialize: ->
    @view = new Bus.Views.Application()
    $('#container').html(@view.render().el)

  index: ->
    map = new Bus.Views.Map()
    map.render()
    navigation = new Bus.Views.Navigation()
    navigation.render()

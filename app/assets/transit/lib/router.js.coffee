class Transit.Router extends Backbone.Router
  routes:
    '': 'index'

  initialize: ->
    @view = new Transit.Views.Application()
    $('#container').html(@view.render().el)

  index: ->
    map = new Transit.Views.Map()
    map.render()
    navigation = new Transit.Views.Navigation()
    navigation.render()

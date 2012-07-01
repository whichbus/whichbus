class Transit.Router extends Backbone.Router
  routes:
    '': 'index'
    'plan': 'plan'

  initialize: ->
    @view = new Transit.Views.Application()
    $('#container').html(@view.render().el)

  index: ->
    @view.render()
    splash = new Transit.Views.Splash()
    @view.$('#content').append(splash.render().el)

  plan: ->
    @view.render()
    map = new Transit.Views.Map()
    map.render()
    navigation = new Transit.Views.Navigation()
    navigation.render()

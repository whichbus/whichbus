class Transit.Router extends Backbone.Router
  routes:
    '': 'index'
    'plan/:from/:to': 'plan'

  initialize: ->
    @view = new Transit.Views.Application()
    $('#container').html(@view.render().el)

  index: ->
    @view.render()
    splash = new Transit.Views.Splash()
    @view.$('#content').append(splash.render().el)

  plan: (from_query, to_query) ->
    if not Transit.plan.get('from') or not Transit.plan.get('to')
      # TODO: Ideally this should accept more than a lat/lon
      from = from_query.split(',')
      to = to_query.split(',')
      Transit.plan.set
        from: { lat: from[0], lon: from[1] }
        to: { lat: to[0], lon: to[1] }
    @view.render()
    map = new Transit.Views.Map()
    map.render()
    navigation = new Transit.Views.Navigation()
    navigation.render()

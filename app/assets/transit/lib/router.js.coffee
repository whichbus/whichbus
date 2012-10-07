class Transit.Router extends Backbone.Router
  routes:
    '?:params': 'index'
    '': 'index'
    'nearby': 'nearby'
    'nearby/:query': 'nearby'
    'plan/:from/:to': 'plan'
    'plan/:from/:to?:params': 'plan'
    'stops/:agency/:code': 'showStop'
    'stops/:id': 'showStop'
    'routes/:agency/:code': 'showRoute'
    'routes/:id': 'showRoute'

  initialize: ->
    window.application = @view = new Transit.Views.Application()
    @view.render()

  index: ->
    @view.render()
    splash = new Transit.Views.Splash()
    @view.$el.html(splash.render().el)

  nearby: (query) ->
    @view.render()
    map = new Transit.Views.Map()

    Transit.mainView = new Transit.Views.Nearby(query: query)
    @view.$('#navigation').append(Transit.mainView.render().el)

  plan: (from_query, to_query, params) ->
    @view.render()
    map = new Transit.Views.Map()

    Transit.mainView = new Transit.Views.Plan(model: Transit.plan, from: from_query, to: to_query)
    @view.$('#navigation').append(Transit.mainView.render().el)

  showStop: (id, code) ->
    @view.render()
    map = new Transit.Views.Map()

    Transit.mainView = new Transit.Views.Stop(model: new Transit.Models.Stop(id: id, agency: id, code: code))

  showRoute: (id, code) ->
    console.log code
    @view.render()
    map = new Transit.Views.Map()

    Transit.mainView = new Transit.Views.Route(model: new Transit.Models.Route(id: id, agency: id, code: code))

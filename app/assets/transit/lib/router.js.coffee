class Transit.Router extends Backbone.Router
  routes:
    '': 'index'
    'plan/:from/:to': 'plan'

  initialize: ->
    @view = new Transit.Views.Application()
    @view.render()

  index: ->
    @view.render()
    splash = new Transit.Views.Splash()
    @view.$el.html(splash.render().el)

  plan: (from_query, to_query) ->
    @view.render()
    map = new Transit.Views.Map()

    plan = new Transit.Views.Plan(model: Transit.plan, from: from_query, to: to_query)
    @view.$('#navigation').append(plan.render().el)

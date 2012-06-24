window.Transit =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    Transit.plan =  new Transit.Models.Plan
    Transit.events = _.extend({}, Backbone.Events)
    Transit.routes = new Transit.Routes
    Backbone.history.start(pushState: true)

$(document).ready ->
  Transit.init()

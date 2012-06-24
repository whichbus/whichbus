window.Transit =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    Transit.events = _.extend({}, Backbone.Events)
    Transit.routes = new Transit.Routes
    Backbone.history.start(pushState: true)

$(document).ready ->
  Transit.init()

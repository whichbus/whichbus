window.Bus =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    Bus.events = _.extend({}, Backbone.Events)
    Bus.routes = new Bus.Routes
    Backbone.history.start(pushState: true)

$(document).ready ->
  Bus.init()

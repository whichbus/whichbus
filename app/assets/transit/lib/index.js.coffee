#= require_self
#
#= require_tree ../templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree .

window.Transit =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    Transit.map = {}
    Transit.plan =  new Transit.Models.Plan
      date: new Date()
      from: lat: 47.63320158032844, lon: -122.36168296958942
      to: lat: 47.618624, lon: -122.320796
    Transit.events = _.extend({}, Backbone.Events)
    Transit.routes = new Transit.Routes
    Backbone.history.start(pushState: true)

$(document).ready ->
  Transit.init()

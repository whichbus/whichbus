#= require_self
#
#= require_tree ../templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require ./utils
#= require_tree .

window.Transit =
  Models: {}
  Collections: {}
  Views: {}
  init: ->
    Transit.map = {}
    Transit.plan = new Transit.Models.Plan(date: new Date())
    Transit.events = _.clone(Backbone.Events)
    Transit.router = new Transit.Router
    Backbone.history.start(pushState: true)

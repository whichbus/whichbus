#= require json2
#= require jquery
#= require spine
#= require spine/manager
#= require spine/ajax
#= require spine/local
#= require spine/route
#= require spine/list
#= require spine/relation

#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

class App extends Spine.Controller
  constructor: ->
    super
    
    # Initialize controllers:
    @whichbus = new App.WhichBus
    window.whichbus = @whichbus
    @append(@whichbus)

    App.Stop.fetch()
    
    Spine.Route.setup()

window.App = App
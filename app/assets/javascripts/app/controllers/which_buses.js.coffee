class App.WhichBus extends Spine.Controller
	className: 'whichbus'
	# elements:
	#   '.items': items
	# 
	# events:
	#   'click .item': 'itemClick'

	constructor: ->
		super

		@main = new App.Main

		@routes
			"/stops/:id": (params) ->
				# show a stop
			"/stops": (params) ->
				@main.stops.active(params)
			"/routes/:id": (params) ->
				# show a route
			"/routes": (params) ->
				@main.routes.active(params)

		@append @main

class App.Main extends Spine.Stack
	controllers:
		stops: App.Stops
		routes: App.Routes
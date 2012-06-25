class App.WhichBus extends Spine.Controller
	className: 'whichbus'
	# elements:
	#   '.items': items
	# 
	# events:
	#   'click .item': 'itemClick'

	constructor: ->
		super

		# sidebar shows stops or routes
		@sidebar = new App.Sidebar

		@routes
			"/stops/:id": (params) ->
				@sidebar.stopShow.active(params)
			"/stops": (params) ->
				@sidebar.stops.active(params)
			"/routes/:id": (params) ->
				@sidebar.routeShow.active(params)
			"/routes": (params) ->
				@sidebar.routes.active(params)

		@append @sidebar

# controller stack for stops and routes
class App.Sidebar extends Spine.Stack
	controllers:
		stops: App.Stops
		routes: App.Routes
		stopShow: App.ShowStop
		routeShow: App.ShowRoute
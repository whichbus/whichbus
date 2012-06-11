class App.Routes extends Spine.Controller
	className: 'routes'

	elements:
		'.route-list': 'items'
		'.filter.routes': 'queryText'
	# 
	events:
		'keyup .filter.routes': 'filter'

	constructor: ->
		super

		@html @view('routes/index')

		@list = new Spine.List
			el: @items
			template: @view('routes/list')

		@active @filter

	filter: ->
		@query = @queryText.val()
		@render()

	render: ->
		# Render a list of the filtered items
		@list.render(App.Route.filter(@query))
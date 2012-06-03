class App.Stops extends Spine.Controller
	className: 'stops'

	elements:
		'.stop-list': 'items'
		'.filter.stops': 'queryText'
	# 
	events:
		'keyup .filter.stops': 'filter'

	constructor: ->
		super

		@html @view('stops/index')

		@list = new Spine.List
			el: @items
			template: @view('stops/list')

		@active @filter

	filter: ->
		@query = @queryText.val()
		@render()

	render: ->
		# Render a template, replacing the controller's HTML
		@list.render(App.Stop.filter(@query))
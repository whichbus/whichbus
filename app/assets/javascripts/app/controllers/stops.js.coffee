class App.Stops.index extends Spine.Controller
	className: 'stops'

	elements:
		'.stop-list': 'items'
		'.filter.stops': 'queryText'
	
	events:
		'keyup .filter.stops': 'filter'

	constructor: ->
		super

		# add some initial HTML to the page
		@html @view('stops/index')

		# create list for displaying the (filtered) set of stops
		@list = new Spine.List
			el: @items
			template: @view('stops/list')

		# bind filter() to active event callback
		@active @filter

	filter: ->
		# update the query string, update the view
		@query = @queryText.val()
		@render()

	render: ->
		# Render a list of the filtered items
		@list.render(App.Stop.filter(@query))
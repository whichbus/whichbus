class App.Routes extends Spine.Controller
	className: 'routes'
		
	elements:
		'.route-list': 'items'
	# 
	events:
		'click body': 'filter'

	constructor: ->
		super

		@html @view('routes/index')

		@list = new Spine.List
			el: @items
			template: @view('routes/list')

		@active @filter

	filter: ->
		@query = '' #@search.val()
		@render()

	render: ->
		console.log 'rendering App.Routes'
		# Render a template, replacing the
		# controller's HTML
		@list.render(App.Route.filter(@query))
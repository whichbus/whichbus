class App.Stops extends Spine.Controller
	elements:
		 '.stop-list': 'items'
	# 
	events:
	   'click body': 'filter'

	constructor: ->
		super

		@html @view('stops/index')

		@list = new Spine.List
			el: @items
			template: @view('stops/list')

		@active @filter

	filter: ->
		@query = '' #@search.val()
		@render()

	render: ->
		console.log 'rendering App.Stops'
		# Render a template, replacing the
		# controller's HTML
		@list.render(App.Stop.filter(@query))
class App.Routes extends Spine.Controller
	className: 'routes'

	elements:
		'.route-list': 'items'
		'.filter.routes': 'queryText'
	# 
	events:
		'keyup .filter.routes': 'filter'
		#'click .route .btn': 'show'

	constructor: ->
		super

		@html @view('routes/index')

		@list = new Spine.List
			el: @items,
			template: @view('routes/list'),
			selectFirst: true
		@list.bind 'change', @change

		App.Route.bind('refresh change', @render)

		@active @filter

	filter: ->
		@query = @queryText.val()
		@render()

	render: =>
		# Render a list of the filtered items
		@list.render(App.Route.filter(@query))

	change: (item) =>
		console.log "clicked! #{item.id}"
		@navigate '/routes', item.id


class App.ShowRoute extends Spine.Controller
	className: 'route'

	# elements:

	# events:

	constructor: ->
		super
		@active @change

	render: ->
		@html @view('routes/show')(@route)

	change: (params) =>
		@route = App.Route.find(params.id)
		@render()

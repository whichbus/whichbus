class Transit.Views.Itinerary extends Backbone.View
	template: JST['templates/itinerary']
	tagName: 'li'
	className: 'itinerary'


	events:
		'mouseover h4': 'map_preview'
		'mouseout h4': 'clean_up'


	initialize: =>
		@map = Transit.map
		@map.from.on 'dragstart', @clean_up
		@map.to.on 'dragstart', @clean_up
		@plan_route = new L.LayerGroup()

	render: =>
		$(@el).html(@template({ trip: @model, index: @model.get('index') }))
		@add_segments()
		this

	add_segments: =>
		for leg in @model.get('legs')
			view = new Transit.Views.Segment(segment: leg)
			view.fetch_prediction()
			@$('.segments').append(view.render().el)


	clean_up: =>
		@plan_route.clearLayers()

	render_map: =>
		@clean_up()
		colors = {'BUS': '#025d8c', 'WALK': 'black', 'FERRY': '#f02311'}
		for leg in @model.get('legs')
			@draw_polyline(leg.legGeometry.points, colors[leg.mode] ? '#1693a5')
		@map.addLayer(@plan_route)

	draw_polyline: (points, color) =>
		points = decodeLine(points)
		latlngs = (new L.LatLng(point[0], point[1]) for point in points)
		polyline = new L.Polyline(latlngs, color: color, opacity: 0.6, clickable: false)
		@plan_route.addLayer(polyline)

	map_preview: =>
		@render_map()

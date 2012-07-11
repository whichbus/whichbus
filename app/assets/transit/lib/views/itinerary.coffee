class Transit.Views.Itinerary extends Backbone.View
	template: JST['templates/itinerary']
	tagName: 'li'
	className: 'itinerary'

	# TODO: move to constant location
	segmentColors: {'BUS': '#025d8c', 'WALK': 'black', 'FERRY': '#f02311'}

	events:
		'mouseover h4': 'render_map'
		'mouseout h4': 'clean_up'

	initialize: =>
		Transit.map.on 'drag:start', @clean_up
		Transit.events.on 'plan:complete', @clean_up
		@plan_route = new L.LayerGroup()

	render: =>
		$(@el).html(@template({ trip: @model, index: @model.get('index') }))
		@add_segments()
		this

	add_segments: =>
		for leg in @model.get('legs')
			# create a view for the segment
			view = new Transit.Views.Segment(segment: leg)
			view.fetch_prediction()
			@$('.segments').append(view.render().el)
			# render the segment's polyline
			poly = Transit.map.create_polyline(leg.legGeometry.points, @segmentColors[leg.mode] ? '#1693a5')
			@plan_route.addLayer(poly)

	clean_up: =>
		Transit.map.leaflet.removeLayer(@plan_route)

	render_map: =>	
		Transit.map.leaflet.addLayer(@plan_route)

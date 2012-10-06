class Transit.Views.Itinerary extends Backbone.View
	template: JST['templates/itinerary']
	tagName: 'li'
	className: 'itinerary'

	# TODO: move to constant location
	segmentColors: 
		BUS: '#025d8c'
		BIKE: 'green'
		WALK: 'black'
		TRAM: '#1693a5'
		FERRY: '#f02311'

	events:
		'mouseover h4': 'render_map'
		'mouseout h4': 'clean_up'
		'click .expand': 'expand_routes'
		'click h4': 'toggle'
		'hover li.segment': 'segmentHover'

	initialize: =>
		Transit.map.on 'drag:start', @clean_up
		Transit.events.on 'plan:complete', @clean_up
		@polylines = []
		@markers =[]

	render: =>
		$(@el).html(@template({ trip: @model, index: @index }))
		@add_segments()
		@toggle() if @index == 0
		@

	add_segments: =>
		index = 0
		for leg in @model.get('legs')
			# create a view for the segment
			view = new Transit.Views.Segment(segment: leg, index: index++)
			view.fetch_prediction()
			view.fetch_safety()
			@$('.segments').append(view.render().el)
			# render the segment's polyline
			poly = Transit.map.create_polyline(leg.legGeometry.points, @segmentColors[leg.mode] ? 'black')
			@polylines.push(poly)
			# create a circle marker at the start of the segment
			marker = Transit.map.create_marker(leg.mode + " " + leg.route, new G.LatLng(leg.from.lat, leg.from.lon),
				# use built-in circle Symbol for the marker (a vector circle)
				path: G.SymbolPath.CIRCLE
				fillColor: @segmentColors[leg.mode] ? 'black'
				fillOpacity: 0.8
				strokeColor: 'black'
				strokeWeight: 1
				scale: 5.5
			)
			@markers.push(marker)

	clean_up: (forced) ->
		# leave polylines on map if this itinerary is active.
		# set forced parameter to true to ignore active status.
		if forced == true or not $(@el).hasClass('active')
			Transit.map.removeLayer @polylines
			Transit.map.removeLayer @markers
		@

	render_map: =>
		Transit.map.addLayer @polylines
		Transit.map.addLayer @markers
		@

	toggle: =>
		# indicate that this itinerary is active
		$(@el).toggleClass 'active'
		@$('.affordance').toggleClass('icon-caret-down').toggleClass('icon-caret-right')
		@$('.segments').slideToggle('fast')

		# determine map overlay appearance based on active state
		active = $(@el).hasClass 'active'
		if active then options = strokeWeight: 4, strokeOpacity: 0.8
		else options = strokeWeight: 6, strokeOpacity: 0.5
		for line in @polylines
			line.setOptions options

	expand_routes: (event) =>
		event.stopPropagation()
		@$('.expandable').show()
		@$('.expand').remove()

	segmentHover: (event) ->
		# toggle opacity of hovered segment to highlight it
		# TODO: make this more noticeable
		index = $(event.currentTarget).data('index')
		@polylines[index].setOptions strokeOpacity: if @polylines[index].strokeOpacity == 1 then 0.8 else 1

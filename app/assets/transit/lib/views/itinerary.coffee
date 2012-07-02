class Transit.Views.Itinerary extends Backbone.View
	template: JST['templates/itinerary']
	className: 'itinerary'
	tagName: 'li'

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
			# show real-time data only for the first bus
			if leg.mode == 'BUS'
				real_time = new Transit.Models.RealTime
					agency: leg.from.stopId.agencyId
					code: leg.from.stopId.id
					trip: leg.tripId
					view: view
				real_time.fetch
					success: (data) =>
						console.log "#{data.get('agency')}/#{data.get('code')} prediction: #{data.readable_delta() or 'unavailable'}"
						data.get('view').$('.real-time').html(data.readable_delta())
						if data.delta_in_minutes()?
								data.get('view').$('.real-time').addClass(data.delta_class()).show()
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

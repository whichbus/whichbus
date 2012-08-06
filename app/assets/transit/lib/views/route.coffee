class Transit.Views.Route extends Backbone.View
	template: JST['templates/route']
	tripTemplate: JST['templates/trip']
	el: '#navigation'
	tagName: 'div'
	className: 'route'

	initialize: =>
		@model.fetch
			success: @render
			error: (model, message) =>
				Transit.errorMessage('Error Loading Route', message)
		@trips = new Transit.Collections.Trips(@model)
		@trips.fetch
			success: @showTrips
		# Transit.events.on 'route:complete', @render

	render: =>
		$(@el).html(@template(route: @model))
		@polylines = Transit.map.create_multi_polyline(@model.get('polylines').split(','), '#025d8c')
		Transit.map.map.addLayer(@polylines)

		@stopMarkers = new L.LayerGroup()
		stopLatlngs = []
		for stop in @model.get('stops')
			stopLatlngs.push pos = new L.LatLng(stop['lat'], stop['lon'])
			@stopMarkers.addLayer(Transit.map.create_marker(stop['name'], pos, Transit.Markers.StopDot, false))
		Transit.map.map.fitBounds(new L.LatLngBounds(stopLatlngs))
		Transit.map.map.addLayer(@stopMarkers)
		this

	showTrips: =>
		list = $("#trips")
		@trips.forEach (item) =>
			list.append(@tripTemplate(trip: item))
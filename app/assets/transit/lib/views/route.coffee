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
				Transit.errorPage('Error Loading Route', message)
		@trips = new Transit.Collections.Trips(@model)
		@trips.fetch
			success: @showTrips
		# Transit.events.on 'route:complete', @render

	render: =>
		$(@el).html(@template(route: @model))
		@polylines = Transit.map.create_multi_polyline(@model.get('polylines').split(','), '#025d8c')
		Transit.map.addLayer @polylines

		@stopMarkers = []
		for stop in @model.get('stops')
			pos = new G.LatLng(stop['lat'], stop['lon'])
			@stopMarkers.push Transit.map.create_marker(stop['name'], pos, Transit.GMarkers.StopDot, false)
			if bounds? then bounds.extend(pos) else bounds = new G.LatLngBounds(pos) 
		Transit.map.map.fitBounds(bounds)
		Transit.map.addLayer(@stopMarkers)
		this

	showTrips: =>
		list = $("#trips")
		@trips.forEach (item) =>
			list.append(@tripTemplate(trip: item))
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

		@tripTimer = setInterval (=> @trips.fetch(success: @showTrips)), 30000
		# Transit.events.on 'route:complete', @render

	favorite: -> {
		name: "#{@model.get('name')}"
		type: 'route'
		url: "routes/#{@model.get('oba_id')}"
	}

	render: =>
		$(@el).html(@template(route: @model))
		Transit.setTitleHTML Transit.Favorites.icon(@model.get('name')), HTML.btn('btn-route', @model.get('name')), @model.get('description')
		@polylines = Transit.map.create_multi_polyline(@model.get('polylines').split(','), '#025d8c')
		Transit.map.addLayer @polylines

		@stopMarkers = []
		for stop in @model.get('stops')
			pos = new G.LatLng(stop['lat'], stop['lon'])
			@stopMarkers.push Transit.map.create_marker(stop['name'] + " (#{stop['direction']})", pos, Transit.GMarkers.StopDot, false, true)
			if bounds? then bounds.extend(pos) else bounds = new G.LatLngBounds(pos) 
		Transit.map.map.fitBounds(bounds)
		Transit.map.addLayer(@stopMarkers)
		this

	showTrips: =>
		list = $("#trips").html('')
		@trips.forEach (item) =>
			list.append(@tripTemplate(trip: item))
			key = "vehicle#{item.get('vehicleId')}"
			pos = Transit.map.latlng item.get('position')
			if Transit.map.hasMarker key then Transit.map.moveMarker key, pos
			else Transit.map.addMarker key, "Vehicle #{item.get('vehicleId')}", pos, Transit.GMarkers.Bus, false, true, G.Animation.DROP


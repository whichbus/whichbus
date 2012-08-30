class Transit.Views.Nearby extends Backbone.View
	template: JST['templates/nearby']
	itemTemplate: JST['templates/nearbystop']

	tagName: 'div'
	className: 'nearby'

	initialize: =>
		# Transit.map.map.addLayer @stopMarkers = new L.LayerGroup()
		# Transit.map.map.setZoom 15
		@stopMarkers = []

		# marker showing search location. dragging it reloads stops
		@searchMarker = Transit.map.create_marker('Your Location', new G.LatLng(0,0), Transit.GMarkers.Start)
		Transit.map.addLayer @searchMarker

		# dragging the map updates the location of the search marker and reloads stops
		google.maps.event.addListener Transit.map.map, 'dragend', => @update(Transit.map.map.getCenter())
		google.maps.event.addListener Transit.map.map, 'zoomend', => @update()

		# finish by geocoding the query
		Transit.map.on 'complete', => Transit.Geocode.lookup
			query: @options.query, 
			success: (location) => 
				@searchMarker.setPosition(pos = new G.LatLng(location.lat, location.lon))
				google.maps.event.addListener @searchMarker, 'dragend', => @loadStops()
				@loadStops()

	render: =>
		$(@el).html(@template())
		this

	update: (latlng) =>
		@searchMarker.setPosition(latlng) if latlng
		google.maps.event.trigger @searchMarker, 'dragend'
		# @searchMarker.fire 'dragend'

	loadStops: =>
		# clean up map, pan to search marker
		pos = @searchMarker.getPosition()
		console.log "loading stops at (#{pos.lat()}, #{pos.lng()})"
		Transit.map.removeLayer @stopMarkers
		@stopMarkers = []
		# @stopMarkers.clearLayers()	
		# @stopMarkers.addLayer(@searchMarker)
		Transit.map.map.panTo pos

		# get the bounds of the map to build the nearby stops query
		bounds = Transit.map.map.getBounds()
		if bounds?
			sw = bounds.getSouthWest()
			ne = bounds.getNorthEast()

		# load stops within the map window
		@stops = new Transit.Collections.Stops
			lat: pos.lat()
			lon: pos.lng()
			latSpan: ne.lat() - sw.lat() ? 0.5
			lonSpan: ne.lng() - sw.lng() ? 0.5
		@stops.fetch
			success: @showStops


	showStops: =>
		# clear the list
		list = @$("#stops").html('')
		# add an entry to the list and a marker to the map for every stop
		@stops.forEach (stop) =>
			list.append(@itemTemplate(stop: stop))
			pos = new G.LatLng(stop.get('lat'), stop.get('lon'))
			@stopMarkers.push Transit.map.create_marker(stop.get('name'), pos, Transit.GMarkers.Stop, false, true)
			Transit.map.addLayer @stopMarkers

class Transit.Views.Nearby extends Backbone.View
	template: JST['templates/nearby']
	itemTemplate: JST['templates/nearbystop']

	tagName: 'div'
	className: 'nearby'

	initialize: =>
		Transit.map.map.addLayer @stopMarkers = new L.LayerGroup()
		# Transit.map.map.setZoom 15

		# marker showing search location. dragging it reloads stops
		@searchMarker = Transit.map.create_marker('Your Location', new L.LatLng(0,0), Transit.Markers.Start)

		# dragging the map updates the location of the search marker and reloads stops
		Transit.map.map.on 'dragend', => @update(Transit.map.map.getCenter())
		Transit.map.map.on 'zoomend', => @update()

		# finish by geocoding the query
		Transit.geocode @options.query, (location) => 
			console.log "geocoded!", location
			@searchMarker.setLatLng(pos = new L.LatLng(location.lat, location.lon))
			@searchMarker.on 'dragend', => @loadStops()
			@loadStops()

	render: =>
		$(@el).html(@template())
		this

	update: (latlng) =>
		@searchMarker.setLatLng(latlng) if latlng
		@searchMarker.fire 'dragend'

	loadStops: =>
		# clean up map, pan to search marker
		pos = @searchMarker.getLatLng()
		console.log "loading stops at (#{pos.lat}, #{pos.lng})"
		@stopMarkers.clearLayers()	
		@stopMarkers.addLayer(@searchMarker)
		Transit.map.map.panTo pos

		# get the bounds of the map to build the nearby stops query
		bounds = Transit.map.map.getBounds()
		sw = bounds.getSouthWest()
		ne = bounds.getNorthEast()

		# load stops within the map window
		@stops = new Transit.Collections.Stops
			lat: pos.lat
			lon: pos.lng
			latSpan: ne.lat - sw.lat
			lonSpan: ne.lng - sw.lng
		@stops.fetch
			success: @showStops


	showStops: =>
		# clear the list
		list = @$("#stops").html('')
		# add an entry to the list and a marker to the map for every stop
		@stops.forEach (stop) =>
			list.append(@itemTemplate(stop: stop))
			pos = new L.LatLng(stop.get('lat'), stop.get('lon'))
			@stopMarkers.addLayer Transit.map.create_marker(stop.get('name'), pos, Transit.Markers.Stop, false, true)

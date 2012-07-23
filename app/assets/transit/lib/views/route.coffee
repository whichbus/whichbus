class Transit.Views.Route extends Backbone.View
	template: JST['templates/route']
	arrivalTemplate: JST['templates/arrival']
	el: '#navigation'
	tagName: 'div'
	className: 'route'

	initialize: =>
		@model.fetch
			success: @render
			error: (model, message) =>
				Transit.errorMessage('Error Loading Route', message)
		# Transit.events.on 'route:complete', @render

	render: =>
		$(@el).html(@template(route: @model))
		@polylines = Transit.map.create_multi_polyline(@model.get('polylines').split(','), '#025d8c')
		Transit.map.map.addLayer(@polylines)

		@stopMarkers = new L.LayerGroup()
		stopLatlngs = []
		for stop in @model.get('stops')
			stopLatlngs.push pos = new L.LatLng(stop['lat'], stop['lon'])
			@stopMarkers.addLayer(Transit.map.create_marker(stop['name'], pos, Transit.Markers.Start))
		Transit.map.map.fitBounds(new L.LatLngBounds(stopLatlngs))
		Transit.map.map.addLayer(@stopMarkers)
		this
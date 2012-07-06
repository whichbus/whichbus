class Transit.Views.Stop extends Backbone.View
	template: JST['templates/stop']
	arrivalTemplate: JST['templates/arrival']
	el: '#navigation'
	tagName: 'div'
	className: 'stop'

	initialize: =>
		@model.fetch
			success: @render
			error: (model, message) =>
				$('.alert').html(message).show()
		@arrivals = new Transit.Collections.Arrivals(@model)
		@arrivals.fetch
			success: @showArrivals
		# Transit.events.on 'route:complete', @render

	render: =>
		$(@el).html(@template(stop: @model))
		stopLocation = new L.LatLng(@model.get('lat'), @model.get('lon'))
		@marker = new L.Marker(stopLocation)
		Transit.map.map.addLayer(@marker).setView(stopLocation, 16)
		this

	showArrivals: =>
		list = $("#arrivals")
		@arrivals.forEach (item) =>
			list.append(@arrivalTemplate(arrival: item))

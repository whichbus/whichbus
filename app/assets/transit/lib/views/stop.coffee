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
				Transit.errorPage('Error Loading Stop', message)
		@arrivals = new Transit.Collections.Arrivals(@model)
		@arrivals.fetch
			success: @showArrivals

	favorite: ->
		name: "#{@model.get('name')}"
		type: 'stop'
		url: "stops/#{@model.get('oba_id')}"

	render: =>
		console.log @model
		$(@el).html(@template(stop: @model))
		Transit.setTitleHTML Transit.Favorites.icon(@model.get('name')), @model.get('name')
		stopLocation = new G.LatLng(@model.get('lat'), @model.get('lon'))
		@marker = Transit.map.create_marker @model.get('name'), stopLocation, Transit.GMarkers.Start, false
		Transit.map.addLayer(@marker) 
		Transit.map.map.panTo stopLocation
		this

	showArrivals: =>
		list = $("#arrivals")
		@arrivals.forEach (item) =>
			list.append(@arrivalTemplate(arrival: item))

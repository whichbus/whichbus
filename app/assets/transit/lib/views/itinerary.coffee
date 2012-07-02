class Transit.Views.Itinerary extends Backbone.View
	template: JST['templates/itinerary']
	
	tagName: 'li'
	className: 'itinerary'

	render: =>	
		$(@el).html(@template({ trip: @model, index: @model.get('index') }))
		@add_segments()
		this

	add_segments: =>
		for leg in @model.get('legs')
			view = new Transit.Views.Segment(segment: leg)
			view.fetch_prediction()

			@$('.segments').append(view.render().el)
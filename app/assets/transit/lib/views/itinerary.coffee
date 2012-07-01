class Transit.Views.Itinerary extends Backbone.View
	template: JST['templates/itinerary']
	className: 'itinerary'
	tagName: 'li'

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
class Transit.Views.Segment extends Backbone.View
	walk_template: JST['templates/segments/walk']
	bus_template: JST['templates/segments/bus']

	tagName: 'li'
	className: 'segment'

	events:
		'click .real-time.label': 'fetch_prediction'

	render: =>
		template = if @options.segment.mode == 'WALK' then @walk_template else @bus_template
		$(@el).html(template(segment: @options.segment)).attr('data-index', @options.index)
		this

	fetch_prediction: =>
		leg = @options.segment
		if leg.mode == 'BUS'
			real_time = new Transit.Models.RealTime
				agency: leg.from.stopId.agencyId
				code: leg.from.stopId.id
				trip: leg.tripId
			real_time.fetch
				success: (data) =>
					console.log "#{data.get('agency')}/#{data.get('code')} prediction: #{data.readable_delta() or 'unavailable'}"
					@$('.real-time').html(data.readable_delta())
					if data.delta_in_minutes()?
							@$('.real-time').addClass(data.delta_class()).show()

	fetch_safety: =>
		if @options.segment.mode == 'BUS'
			s = new Transit.Models.Stop
				agency: @options.segment.to.stopId.agencyId
				code: @options.segment.to.stopId.id
			s.fetch
				success: (data)->
					safetyNumber = data.get('safety') or -1
					console.log("safety = #{safetyNumber} where stopId = #{data.get('code')}")
					if(safetyNumber? and safetyNumber > 10) # Magic number...
						console.log "showing safety warning for possibly unsafe stop"
						@$('.safety').attr('data-safety', safetyNumber).show() # this is selecting all safety classes, not just the one in the template
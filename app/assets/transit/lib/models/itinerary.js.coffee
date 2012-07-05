class Transit.Models.Itinerary extends Backbone.Model
	summary: =>
		# TODO: case with no bus legs
		_.pluck(_.filter(@get('legs'), (leg) -> leg.mode == 'BUS'), 'route').join(', ')

	timing: =>
		start = Transit.format_time(@get('startTime'))
		end   = Transit.format_time(@get('endTime'))
		total = Transit.format_duration(@get('duration') / 1000)
		"#{start} - #{end} (#{total})"

	duration: =>
		walk = Transit.format_duration(@get('walkTime'), true)
		wait = Transit.format_duration(@get('waitingTime'), true)
		bus = Transit.format_duration(@get('transitTime'), true)
		"#{walk} walking, #{wait} waiting, #{bus} transit"
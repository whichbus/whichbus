class Transit.Models.Itinerary extends Backbone.Model
	summary: =>
		_.pluck(_.filter(@get('legs'), (leg) -> leg.mode not in ['WALK', 'BIKE']), 'route').join(', ')

	summaryHTML: =>
		_.map(_.filter(@get('legs'), (leg) -> leg.mode not in ['WALK', 'BIKE']), (leg) -> 
			"<span class='btn btn-route'>#{if leg.mode == 'FERRY' then 'FERRY' else leg.route}</span>"
		).join(' ')

	timing: =>
		start = Transit.format_time(@get('startTime'))
		end   = Transit.format_time(@get('endTime'))
		total = Transit.format_duration(@get('duration') / 1000)
		"#{start} - #{end} (#{total})"

	duration: =>
		walk = Transit.format_duration(@get('walkTime'), true)
		wait = Transit.format_duration(@get('waitingTime'), true)
		bus = Transit.format_duration(@get('transitTime'), true)
		"#{walk} walking, #{bus} transit"
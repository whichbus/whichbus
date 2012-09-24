class Transit.Models.Itinerary extends Backbone.Model
	summary: =>
		_.pluck(_.filter(@get('legs'), (leg) -> leg.mode not in ['WALK', 'BIKE']), 'route').join(', ')

	summaryHTML: =>
		index = 0
		stops = _.map(_.filter(@get('legs'), (leg) -> leg.mode not in ['WALK', 'BIKE']), (leg) -> 
			index++
			expandable = if index > 2 then ' expandable' else ''
			route = if leg.mode == 'FERRY' then 'FERRY' else leg.route
			"<span class='btn btn-route#{expandable}'>#{route}</span>"
		).join(' ')
		stops = "#{stops} <span class='btn btn-route expand'>+#{index-2}</span>" if index > 2
		return stops

	timing: =>
		start = Transit.format_time(@get('startTime'))
		end   = Transit.format_time(@get('endTime'))
		total = Transit.format_duration(@get('duration') / 1000)
		"#{start}–#{end} (#{total})"

	duration: =>
		walk = Transit.format_duration(@get('walkTime'), true)
		wait = Transit.format_duration(@get('waitingTime'), true)
		bus = Transit.format_duration(@get('transitTime'), true)
		"#{walk} walking, #{bus} transit"

class Transit.Models.Arrival extends Backbone.Model
	# urlRoot: '/workshop/stops/:id/arrivals'

	hasPrediction: => @get('predictedArrivalTime') > 0

	arrivalTime: =>
		if @hasPrediction() then @get('predictedArrivalTime') else @get('scheduledArrivalTime')

	arrivalOffset: => (@get('predictedArrivalTime') - @get('scheduledArrivalTime')) / 1000

	delta_in_minutes: =>
		predicted = @get('predictedArrivalTime')
		if predicted > 0
		  Math.round((@get('scheduledArrivalTime') - predicted)/60000)

	readable_delta: =>
		# return 'scheduled' unless @hasPrediction()
		delta = @delta_in_minutes()
		if delta > 0
	  		"#{delta} minute#{if delta > 1 then 's' else ''} early"
		else if delta < 0
  			"#{Math.abs(delta)} minute#{if delta < -1 then 's' else ''} late"
		else if delta == 0 
			'on time'
		else null

	delta_class: =>
		return '' unless @hasPrediction()
		
		delta = @delta_in_minutes()
		if delta == 0 then 'on-time label-info'
		else if delta > 0 then 'early label-success'
		else 'late label-important'
class Transit.Models.Arrival extends Backbone.Model
	# urlRoot: '/workshop/stops/:id/arrivals'

	hasPrediction: => @get('predictedArrivalTime') > 0

	arrivalTime: =>
		if @hasPrediction() then @get('predictedArrivalTime') else @get('scheduledArrivalTime')

	arrivalOffset: => (@get('predictedArrivalTime') - @get('scheduledArrivalTime')) / 1000

	deviation: =>
		predicted = @get('predictedArrivalTime')
		if predicted > 0
		  Math.round((@get('scheduledArrivalTime') - predicted)/60000)
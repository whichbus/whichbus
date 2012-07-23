class Transit.Models.Trip extends Backbone.Model
	# urlRoot: '/workshop/stops/:id/arrivals'

	hasPrediction: => @get('predicted')

	offset_in_minutes: =>
  		Math.round(@get('nextStopTimeOffset')/ 60)

	deviation_in_minutes: =>
  		Math.round(@get('scheduleDeviation')/ 60)
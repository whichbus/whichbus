class Transit.Models.RealTime extends Backbone.Model

  sync: (method, model, options) =>
    if method == 'read'
      agency_id = @get('segment').from.stopId.agencyId
      stop_id = @get('segment').from.stopId.id
      $.get "/workshop/stops/#{agency_id}/#{stop_id}/arrivals", (response) =>
        # find the prediction from OBA with the same trip id as in OTP
        trip = _.find response, (prediction) =>
          prediction.tripId.split('_')[1] == @get('segment').tripId
        options.success trip
      .error -> options.error 'Real-time data not available.'
    else options.error 'Real-time data is read-only.'


  delta_in_minutes: =>
    predicted = @get('predictedArrivalTime')
    if predicted > 0
      Math.round((@get('scheduledArrivalTime') - predicted)/60000)

  readable_delta: =>
    delta = @delta_in_minutes()
    if delta > 0
      "#{delta} #{if delta > 1 then 'minutes' else 'minute'} early"
    else if delta < 0
      "#{Math.abs(delta)} #{if delta < -1 then 'minutes' else 'minute'} late"
    else if delta == 0
      'on time'
    else ''

  delta_class: =>
    if @delta_in_minutes() == 0 then 'on-time label-info'
    else if @delta_in_minutes() > 0 then 'early label-success'
    else 'late label-important'

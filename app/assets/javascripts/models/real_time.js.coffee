class Transit.Models.RealTime extends Backbone.Model

  sync: (method, model, options) =>
    if method == 'read'
      @get_agency_id @get('segment').agencyId, (response) =>
        # OBA gives a response with an invalid content type, force it to json
        oba_stop_id = "#{response.oba_id}_#{@get('segment').from.stopId.id}"
        $.ajax
          url: "/oba/where/arrivals-and-departures-for-stop/#{oba_stop_id}.json"
          data:
            key: 'TEST'
            # TODO: Play around with this value, may need to accommodate walking.
            #time: @get('segment').startTime
            #minutesBefore: 10
            #minutesAfter: 60
          success: (real_time) =>
            if real_time.code == 200
              oba_trip_id = "#{response.oba_id}_#{@get('segment').tripId}"
              # find the prediction from OBA with the same trip id as in OTP
              trip = _.find real_time.data.arrivalsAndDepartures, (prediction) ->
                prediction.tripId == oba_trip_id
              options.success trip
            else options.error real_time.text
          dataType: 'json'
    else options.error 'Real-time data is read-only.'


  get_agency_id: (name, callback) =>
    # TODO: get the onebusaway agency id from the agency name, cache this!
    $.get "/workshop/agencies/otp/#{name}.json", callback


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

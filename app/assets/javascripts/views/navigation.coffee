class Bus.Views.Navigation extends Backbone.View
  template: JST['navigation']
  el: 'div#navigation'

  events:
    'submit': 'plan'
    'click #from-location': 'from_current_location'
    'click #to-location': 'to_current_location'

  initialize: =>
    Bus.events.on 'plan:complete', @add_segments
    Bus.events.on 'plan:complete', @get_real_time
    Bus.events.on 'plan:clear', @render
    Bus.events.on 'real_time:complete', @render_real_time

  render: =>
    $(@el).html(@template())
    this

  plan: (event) ->
    event.preventDefault()
    from_query = @$('#from_query').val()
    to_query = @$('#to_query').val()
    from_data = {
      format: 'json', q: from_query, countrycodes: 'US'
    }
    to_data = {
      format: 'json', q: to_query, countrycodes: 'US'
    }
    # TODO: This is fugly, need to batch it
    $.get '/nominatim/v1/search', from_data, (from_response) =>
      $.get '/nominatim/v1/search', to_data, (to_response) =>
        Bus.events.trigger 'geocode:complete', from_response[0], to_response[0]


  _first_transit_leg: (segments) ->
    _.find segments, (segment) ->
      segment.mode != 'WALK'

  add_segments: (plan) =>
    @$('.trip').html('')
    segments = plan.itineraries[0].legs
    first_transit_leg = @_first_transit_leg(segments)
    for leg in segments
      if first_transit_leg.tripId == leg.tripId
        leg.real_time = true
      view = new Bus.Views.Segment(segment: leg)
      @$('.trip').append(view.render().el)

  # TODO: Use leaflet's map.locate()
  from_current_location: =>
    navigator.geolocation.getCurrentPosition (position) ->
      @$('#from_query').val("#{position.coords.latitude},#{position.coords.longitude}")

  to_current_location: =>
    navigator.geolocation.getCurrentPosition (position) ->
      @$('#to_query').val("#{position.coords.latitude},#{position.coords.longitude}")

  get_real_time: (plan) =>
    segments = plan.itineraries[0].legs
    first_transit_leg = @_first_transit_leg(segments)
    # TODO: get the onebusaway agency id from the agency name, cache this!
    $.get "/workshop/agencies/otp/#{first_transit_leg.agencyId}.json", (response) =>
      # OBA gives a response with an invalid content type, force it to json
      $.ajax
        url: "/oba/where/arrivals-and-departures-for-stop/#{response.oba_id}_#{first_transit_leg.from.stopId.id}.json"
        # TODO: put the actual time in here, defaults to NOW
        data: { key: 'TEST' }
        success: (real_time) ->
          oba_trip_id = "#{response.oba_id}_#{first_transit_leg.tripId}"
          Bus.events.trigger 'real_time:complete', real_time.data.arrivalsAndDepartures, oba_trip_id
        dataType: 'json'


  render_real_time: (data, oba_trip_id) =>
    # find the prediction from OBA with the same trip id as in OTP
    trip = _.find data, (prediction) ->
      prediction.tripId == oba_trip_id

    # don't show anything if we don't have data
    readable_time_delta = ''

    if trip?
      time_delta = Math.round((trip.scheduledArrivalTime - trip.predictedArrivalTime)/60000)

      # TODO: Noticed several outliers, figure out what's causing them
      if Math.abs(time_delta) < 360
        # TODO: Move tags stuff into templates
        if time_delta > 0
          readable_time_delta = "<span class=\"label label-success early\">#{Math.abs(time_delta)} minute#{if time_delta > 1 then 's' else ''} early</span>"
        else if time_delta < 0
          readable_time_delta = "<span class=\"label label-important late\">#{Math.abs(time_delta)} minute#{if time_delta < -1 then 's' else ''}  late</span>"
        else 
          readable_time_delta = '<span class=\"label on-time\">on time</span>'

    @$('.real-time').append(readable_time_delta)
    

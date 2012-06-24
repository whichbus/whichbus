class Transit.Models.Plan extends Backbone.Model
  urlRoot: '/otp/plan'
  defaults:
    itineraries: []
    desired_itineraries: 1

  parse: (plan) =>
    @set
      date: new Date(plan.date)
      from: plan.from
      to: plan.to
      itineraries: new Transit.Collections.Itineraries(plan.itineraries)

  sync: (method, model, options) =>
    if method == 'read'
      $.get @url(), @request(), (response) =>
        # OTP returns status 200 for everything, so handle response manually
        if response.error?
          options.error response.error.msg
        else options.success response.plan
    else options.error 'Plan is read-only.'

  request: =>
    date: @get('date').toDateString()
    time: @get('date').toTimeString()
    fromPlace: "#{@get('from').lat},#{@get('from').lon}"
    toPlace: "#{@get('to').lat},#{@get('to').lon}"
    numItineraries: @get('desired_itineraries')

  geocode: (query, callback) ->
    $.get '/nominatim/v1/search'
      format: 'json'
      countrycodes: 'US'
      q: query
    .success(callback)
    .error ->
      console.log "Failed to geocode #{query}."

  geocode_from: (query) =>
    @geocode query, (response) =>
      @set 'from', lat: response[0].lat, lon: response[0].lon if response[0]?

  geocode_to: (query) =>
    @geocode query, (response) =>
      @set 'to', lat: response[0].lat, lon: response[0].lon if response[0]?

class Transit.Models.Plan extends Backbone.Model
  urlRoot: '/api/otp/plan'
  defaults:
    itineraries: []
    desired_itineraries: 3
    arrive_by: false
    modes: ['TRANSIT','WALK']
    optimize: 'QUICK'

  initialize: =>
    # create a local storage for the geocode data
    @geocode_storage = Transit.storage_get('geocode')

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
    date: Transit.format_otp_date(@get('date'))
    time: Transit.format_otp_time(@get('date'))
    arriveBy: @get('arrive_by')
    mode: @get('modes').join()
    optimize: @get('optimize')
    fromPlace: "#{@get('from').lat},#{@get('from').lon}"
    toPlace: "#{@get('to').lat},#{@get('to').lon}"
    numItineraries: @get('desired_itineraries')

  geocode_from_to: (from_query, to_query) =>
    # TODO: It would be nice to batch this instead of doing 2 queries.
    Transit.Geocode.lookup
      query: unescape(from_query)
      modal: true
      success: (from) =>
        Transit.Geocode.lookup
          query: unescape(to_query)
          modal: true
          success: (to) =>
            # geocode method returns one result instead of array
            if from? and to?
              @set
                from: lat: from.lat, lon: from.lon
                to: lat: to.lat, lon: to.lon
              @trigger 'geocode'
            else 
              message = ""
              message += "Unable to understand starting point '#{unescape(from_query)}.'<br/>" unless from?
              message += "Unable to understand destination '#{unescape(to_query)}.'<br/>" unless to?
              message += "Please provide a specific address or neighborhood. Intersections are not supported and businesses are flaky at this time."
              @trigger 'geocode:error', message


  current_location: (selector, target) =>
    # TODO: Use leaflet's map.locate()
    navigator.geolocation.getCurrentPosition (pos) =>
      latitude = pos.coords.latitude.toFixed(7)
      longitude = pos.coords.longitude.toFixed(7)
      selector.val "#{latitude},#{longitude}"
      @set target, lat: latitude, lon: longitude
      @trigger 'geolocate'

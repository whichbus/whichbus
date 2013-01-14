# A one-stop shop for all your asynchronous geocoding needs. 
Transit.Geocode =
  # the cache object for storing saved geocodes
  geocache: Transit.storage_get('geocode')

  defaultLocation: new G.LatLng(47.6097, 122.3331)

  # the geocoder itself! thanks Google
  geocoder: new google.maps.Geocoder()

  initialize: (map) ->
    # initalize Places service using Google map object (tricky Google!)
    @places = new google.maps.places.PlacesService(map)

  # performs geocode request using Google Places if available with automatic
  # fallback to Google Geocoder.
  geocode: (query, callback) ->
    # @query = query
    # coverage = Transit.map.get('coverage') 
    # translate to google.maps.LatLngBounds unless already using Google
    # unless GOOGLE?
    #   sw = coverage.getSouthWest()
    #   ne = coverage.getNorthEast()
    #   coverage = new G.LatLngBounds(new G.LatLng(sw.lat, sw.lng), new G.LatLng(ne.lat, ne.lng))
    if @places?
      location = if Transit.currentPosition then Transit.map.latlng(Transit.currentPosition) else @defaultLocation
      console.log "PLACES query '#{query}' near", location
      @places.nearbySearch 
        keyword: query
        location: location
        radius: 50000
      , callback
    else
      console.log "GEOCODER query '#{query}'"
      @geocoder.geocode { address: query, bounds: coverage }, callback

  # This method handles three query cases:
  #   1. latitude,longitude pair => return it
  #   2. address => geocode it using a geocoding service, return coordinates
  #   3. null or "here" => return user's current position
  # Provide a success callback method that will receive an object containing keys 
  # 'lat', 'lon', and 'address' OR undefined if geocode fails.
  # Optionally provide error callback that will receive geocoder error code.
  # Supported options:
  #   query - the query string
  #   success - success callback
  #   error - error callback. if none provided then calls success(undefined)
  #   modal - boolean whether user should see dialog to disambiguate between results. if not, returns first result.
  #   save - boolean indicates whether to save result to cache (not implemented)
  lookup: (options) ->
    # TODO: TEST what happens if no callbacks are given / empty hash?
    # if query exists and is not the string "here"...
    if options.query? and options.query isnt "here"
      query = unescape(options.query.replace(/\+/g, '  '))
      
      # HACK SAUCE FISH PARTY! geocoder returns something ridiculous for 'space needle' w/o city
      if /space needle/i.test query then query = "space needle, seattle"

      # if the query is already a lat,lon pair then simply use that as location
      latLon = /^(-?\d+\.\d+),(-?\d+\.\d+)$/.exec(query)
      if latLon?
        options.success({ lat: latLon[1], lon: latLon[2] })
      # otherwise perform a quick storage lookup
      else if @cache(query)?
        options.success @cache(query)
      # finally, call the Google geocoding service
      else
        # kick off the request
        @geocode query, (results, status) =>
          if status == google.maps.GeocoderStatus.OK
            console.log "GEOCODE RESULTS (#{results.length}):", results
            results = _.map results, (item) ->
              # trim zip code and country from formatted address
              address: item.name or (/^(.+)\d{5}/.exec(item.formatted_address)?[1] ? item.formatted_address)
              vicinity: item.vicinity
              lat: item.geometry.location.lat()
              lon: item.geometry.location.lng()
            if options.modal and results.length > 1
              disambiguate query, results, options.success
            else return options.success results[0]
          else
            console.error "Failed to geocode #{query}: #{status}", results
            # callback with undefined parameter means there was an error
            if options.error? then options.error(status) else options.success()
    # if query does not exist then use current position
    else @getCurrentPosition options.success

  getCurrentPosition: (callback) ->
    success = (position) ->
      Transit.currentPosition =
        lat: position.coords.latitude.toFixed(7)
        lng: position.coords.longitude.toFixed(7)
      if callback
        callback
          address: 'Current Location'
          lat: Transit.currentPosition.lat
          lon: Transit.currentPosition.lng
    # error = -> callback()
    navigator.geolocation.getCurrentPosition success, -> Transit.events.trigger('geocode:fail')

  # convenient method to get or set a value in the geocode cache.
  # if value is provided then it is saved in cache. otherwise value of key is returned.
  cache: (key, value=null) ->
    if value?
      @geocache[key] = value
      Transit.storage_set 'geocode', @geocache
      console.log "GEOCACHE SET: #{key} => #{value}"
    @geocache[key]

  # convenient method to remove a value from the geocode cache.
  # if key is undefined then the entire cache is cleared.
  cacheClear: (key) ->
    if key?
      delete @geocache[key]
      console.log "GEOCACHE CLEAR: #{key}"
    else 
      @geocache = {}
      console.log "GEOCACHE RESET"
    Transit.storage_set 'geocode', @geocache

# allow user to disambiguate multiple results through modal dialog.
disambiguate = (query, results, callback) ->
  console.log "disambiguating #{query}:", results
  modal = new Transit.Views.Modal(query: query, results: results, callback: callback)
  modal.template = JST['templates/disambiguate']
  # when a button is clicked, call the callback with the geocode result corresponding to button
  modal.success = (btn) ->
    # get clicked result using index from btn href (chomp leading #)
    result = @options.results[btn.attr('href').slice(1)]
    # save result to geocache if checkbox is checked
    if @$('#save')[0].checked then Transit.Geocode.cache(@options.query, result)
    # callback with the geocode result
    @options.callback result
  # BOOM show the modal!
  modal.render()

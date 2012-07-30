# A one-stop shop for all your asynchronous geocoding needs. 

# This method handles three query cases:
# 1. latitude,longitude pair => return it
# 2. address => geocode it using Nominatim, return geocoded location
# 3. null or "here" => return user's current position

# Provide a callback method that will be given an object containing 
# keys 'lat' and 'lon' (and possibly other things, in the case of an address).

Transit.geocode = (query, callback) ->
  # if query exists and is not the string "here"...
  if query? and query != "here"
    query = unescape(query)
    geocode_storage = Transit.storage_get('geocode')
    # if the query is already a lat,lon pair then simply use that as location
    latLon = /^(-?\d+\.\d+),(-?\d+\.\d+)$/.exec(query)
    if latLon?
      callback({ lat: latLon[1], lon: latLon[2] })
    # retrieve the location from the local storage if possible
    else if geocode_storage[query]?
      callback(geocode_storage[query])
    # call the geocoding service to turn an arbitrary address string into a mappable location
    else
      bounds = Transit.map.leaflet?.getBounds()
      $.ajax
        type: 'GET'
        dataType: 'jsonp'
        url: 'http://open.mapquestapi.com/nominatim/v1/search?json_callback=?'
        data:
          format: 'json'
          countrycodes: 'US'
          viewbox: bounds?.toBBoxString()
          q: query
      .success (response) =>
        # save the first result in the local storage
        geocode_storage[query] = response[0]
        Transit.storage_set('geocode', geocode_storage)
        callback(response[0])
      .error ->
        console.log "Failed to geocode #{query}."
  # if query does not exist then use current position
  else
    navigator.geolocation.getCurrentPosition (position) ->
      callback(lat: position.coords.latitude.toFixed(7), lon: position.coords.longitude.toFixed(7))

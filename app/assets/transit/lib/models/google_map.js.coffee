window.G = google.maps

G.LatLng.prototype.toArray = () -> [@lat(), @lng()]
G.LatLng.prototype.toHash = () -> lat: @lat(), lon: @lng()

class Transit.Models.GoogleMap extends Backbone.Model
  urlRoot: '/api/otp/metadata'

  defaults:
    fit_bounds: true

  initialize: ->
    mapOptions =
      center: new G.LatLng(47.62167, -122.349072)
      zoom: 13
      mapTypeId: G.MapTypeId.ROADMAP
      mapTypeControl: false
      streetViewControl: false
      zoomControl: true
      zoomControlOptions:
        style: google.maps.ZoomControlStyle.DEFAULT
    @map = new G.Map(@get('el'), mapOptions)

    @on 'change:from change:to', @update_markers
    @fetch()

  parse: (data) =>
    southWest = new G.LatLng(data.lowerLeftLatitude, data.lowerLeftLongitude)
    northEast = new G.LatLng(data.upperRightLatitude, data.upperRightLongitude)
    @set
      coverage: new G.LatLngBounds(southWest, northEast)
    @trigger 'complete'

  update_marker: (attribute) =>
    marker_name = "#{attribute}_marker"
    point = new G.LatLng(@get(attribute).lat, @get(attribute).lon)
    if not @has(marker_name)
      # marker hasn't been added to the map yet, create it
      @create_marker(attribute, point, Transit.GMarkers.Start)
    else
      # marker is already on the map, update its location
      @get(marker_name).setPosition(point)

  update_markers: =>
    # create or update markers from given coordinates
    # if @hasChanged('from') or @hasChanged('to')
    console.log 'GoogleMap plan changed:', @get('from'), @get('to')
    @update_marker('from') if @hasChanged('from')
    @update_marker('to') if @hasChanged('to')
    # trigger a single custom event when from and/or to change
    @trigger 'change:markers'

  latlng: (param) -> 
    # create as an array [lat, lon]
    if _.isArray param then new G.LatLng param[0], param[1]
    # or as a hash { lat:?, lon:? }
    else if _.isObject param then new G.LatLng param.lat, param.lon
    # or as two parameters latlng(lat, lon)
    else new G.LatLng(arguments[0], arguments[1] ? arguments[0])

  # creates a polyline with the set of points and given color
  create_polyline: (points, color = '#000', weight = 5, opacity = 0.6) ->
    points = G.geometry.encoding.decodePath(points)
    new G.Polyline
      path: points,
      strokeColor: color,
      strokeWeight: weight,
      strokeOpacity: opacity

  # creates an array of polylines for each set of points in the given array
  create_multi_polyline: (polylinesArray, color) ->
    polylines = []
    for poly in polylinesArray
      polylines.push @create_polyline(poly, color)
    polylines

  # create a marker with the five most common options
  create_marker: (name, position, icon, draggable=true, clickable=false) ->
    marker = new G.Marker
      title: name
      position: position
      clickable: clickable
      draggable: draggable
      icon: icon
    # do not add marker to the map yet, that's what @addLayer is for
    marker

  # creates marker, saves it in the map's attributes using the key, and adds it to the map.
  # also adds dragstart and dragend events that trigger drag:event:key Backbone events.
  addMarker: (key, name, position, icon, draggable=true, clickable=false, animation) ->
    marker = @create_marker name, position, icon, draggable, clickable
    @set key, marker, silent: true
    marker.setAnimation(animation) if animation? 
    @addLayer marker

    console.log "new marker: #{key} => #{name}", marker

    # update location after the drag, trigger a drag event on a drag
    G.event.addListener marker, 'dragstart', =>
      @trigger "drag:start drag:start:#{key}"

    G.event.addListener marker, 'dragend', =>
      # @set(key, lat: marker.getPosition().lat(), lon: marker.getPosition().lng())
      @trigger "drag:end drag:end:#{key}"

    marker

  # moves the marker with the given key to the given position.
  # accept many formats of position: G.LatLng, array [lat, lon], hash {lat:?, lon:?}
  moveMarker: (key, position) ->
    marker = @get key
    if position instanceof G.LatLng
      marker.setPosition(position)
    else if _.isArray position
      marker.setPosition new G.LatLng(position[0], position[1])
    else
      marker.setPosition new G.LatLng(position.lat, position.lon)

  # remove marker from map and delete from attributes, then return it.
  removeMarker: (key) ->
    marker = @get key
    if marker?
      @unset key
      @removeLayer marker
      marker

  hasMarker: (key) -> @get(key)?

  # adds an item or array of items to the map
  addLayer: (mapLayer) ->
    if _.isArray mapLayer
      item.setMap @map for item in mapLayer
    else
      mapLayer?.setMap @map

  # removes an item or array of items from the map
  removeLayer: (mapLayer) ->
    if _.isArray mapLayer
      item.setMap null for item in mapLayer
    else
      mapLayer?.setMap null

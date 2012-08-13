window.G = google.maps

class Transit.Models.GoogleMap extends Backbone.Model
  urlRoot: '/api/otp/metadata'

  defaults:
    fit_bounds: true

  initialize: (attributes) =>
    mapOptions =
      center: new google.maps.LatLng(47.62167, -122.349072)
      zoom: 13
      mapTypeId: google.maps.MapTypeId.ROADMAP
      zoomControl: true
      zoomControlOptions:
        style: google.maps.ZoomControlStyle.DEFAULT
    @map = new google.maps.Map(document.getElementById('map'), mapOptions)

    #@map.attributionControl.setPrefix('')

    @addLayer @create_marker 'from', @latlng(0, 0), Transit.GMarkers.Start 
    @addLayer @create_marker 'to', @latlng(0, 0), Transit.GMarkers.End

    # @on 'change:south_west change:north_east', @set_max_bounds
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
    point = @latlng(@get(attribute).lat, @get(attribute).lon)
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

  latlng: (lat, lng) ->
    new google.maps.LatLng(lat, lng)

  create_polyline: (points, color) ->
    points = google.maps.geometry.encoding.decodePath(points)
    new google.maps.Polyline
      path: points,
      strokeColor: color,
      strokeOpacity: 0.8,
      strokeWeight: 5

  create_multi_polyline: (polylinesArray, color) ->
    polylines = []
    for poly in polylinesArray
      polylines.push @create_polyline(poly, color)
    polylines

  create_marker: (name, position, icon, draggable=true, clickable=false) ->
    marker = new google.maps.Marker
      title: name
      position: position
      clickable: clickable
      draggable: draggable
      icon: icon
      # map: @map
    console.log "new marker #{name}", marker 
    # update location after the drag, trigger a drag event on a drag
    google.maps.event.addListener marker, 'dragstart', =>
      @trigger "drag drag:start drag:start:#{name}"
    google.maps.event.addListener marker, 'dragend', =>
      @set(name, lat: marker.getPosition().lat(), lon: marker.getPosition().lng())
      @trigger "drag drag:end drag:end:#{name}"
    # add marker to map and model
    # @map.addLayer(marker)
    @set "#{name}_marker", marker, silent: true
    return marker

  addLayer: (mapLayer) ->
    if _.isArray mapLayer
      item.setMap @map for item in mapLayer
    else
      mapLayer.setMap @map

  removeLayer: (mapLayer) ->
    if _.isArray mapLayer
      item.setMap null for item in mapLayer
    else
      mapLayer.setMap null
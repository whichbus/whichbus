class Transit.Models.Map extends Backbone.Model
  urlRoot: '/api/otp/metadata'

  defaults:
    fit_bounds: true

  initialize: (attributes) =>
    mapOptions =
      center: new google.maps.LatLng(47.62167, -122.349072),
      zoom: 13,
      disableDefaultUI: true
      zoomControl: true
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map(document.getElementById('map'), mapOptions)

    #@map.addLayer @create_marker('from', new L.LatLng(0,0), Transit.Markers.Start)
    #@map.addLayer @create_marker('to', new L.LatLng(0,0), Transit.Markers.End)

    #@on 'change:south_west change:north_east', @set_max_bounds
    #@on 'change', @update_markers
    @fetch()

  parse: (data) =>
    #@set
    #  south_west: new L.LatLng data.lowerLeftLatitude, data.lowerLeftLongitude
    #  north_east: new L.LatLng data.upperRightLatitude, data.upperRightLongitude

  set_max_bounds: =>
    #@map.setMaxBounds new L.LatLngBounds(@get('south_west'), @get('north_east'))

  update_marker: (attribute) =>
    marker_name = "#{attribute}_marker"
    point = new L.LatLng(@get(attribute).lat, @get(attribute).lon)
    if not @has(marker_name)
      # marker hasn't been added to the map yet, create it
      @create_marker(attribute, point, Transit.Markers.Start)
    else
      # marker is already on the map, update its location
      @get(marker_name).setLatLng(point)

  update_markers: =>
    # create or update markers from given coordinates
    if @hasChanged('from') or @hasChanged('to')
      @update_marker('from') if @hasChanged('from')
      @update_marker('to') if @hasChanged('to')
      # trigger a single custom event when from and/or to change
      @trigger 'change:markers'

  create_polyline: (points, color) ->
    points = google.maps.geometry.encoding.decodePath(points)
    new google.maps.Polyline
      path: points,
      strokeColor: color,
      strokeOpacity: 1.0,
      strokeWeight: 2

  create_multi_polyline: (pointsArray, color) ->
    latlngs = []
    for points in pointsArray
      points = decodeLine(points)
      latlngs.push(new L.LatLng(point[0], point[1]) for point in points)
    new L.MultiPolyline(latlngs, color: color, opacity: 0.6, clickable: false)

  create_marker: (name, position, icon, draggable=true, clickable=false) ->
    marker = new L.Marker(position, clickable: clickable, draggable: draggable, icon: new icon())
    # update location after the drag, trigger a drag event on a drag
    marker.on 'dragstart', =>
      @trigger "drag drag:start drag:start:#{name}"
    marker.on 'dragend', =>
      @set(name, lat: marker.getLatLng().lat, lon: marker.getLatLng().lng)
      @trigger "drag drag:end drag:end:#{name}"
    # add marker to map and model
    # @map.addLayer(marker)
    @set "#{name}_marker", marker, silent: true
    return marker


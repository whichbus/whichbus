class Transit.Models.Map extends Backbone.Model
  urlRoot: '/api/otp/metadata'

  defaults:
    api_url: 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
    <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
    &copy; <a href="http://mapbox.com/">Mapbox</a>'
    fit_bounds: true

  initialize: (attributes) =>
    @leaflet = @map = new L.Map attributes.element,
      center: new L.LatLng(47.62167,-122.349072)
      zoom: 13
      maxZoom: 17
    tiles = new L.TileLayer(@get('api_url'), attribution: @get('attribution'))
    @map.attributionControl.setPrefix('')
    @map.addLayer(tiles)
    @on 'change:south_west change:north_east', @set_max_bounds
    @on 'change', @update_markers
    @fetch()

  parse: (data) =>
    @set
      south_west: new L.LatLng data.lowerLeftLatitude, data.lowerLeftLongitude
      north_east: new L.LatLng data.upperRightLatitude, data.upperRightLongitude

  set_max_bounds: =>
    @map.setMaxBounds new L.LatLngBounds(@get('south_west'), @get('north_east'))

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

  create_polyline: _.memoize (points, color) ->
    points = decodeLine(points)
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    new L.Polyline(latlngs, color: color, opacity: 0.6, clickable: false)

  create_marker: (name, position, icon) ->
    marker = new L.Marker(position, clickable: false, draggable: true, icon: new icon())
    # update location after the drag, trigger a drag event on a drag
    marker.on 'dragstart', =>
      @trigger "drag drag:start drag:start:#{name}"
    marker.on 'dragend', =>
      @set(name, lat: marker.getLatLng().lat, lon: marker.getLatLng().lng)
      @trigger "drag drag:end drag:end:#{name}"
    # add marker to map and model
    @map.addLayer(marker)
    @set "#{name}_marker", marker, silent: true


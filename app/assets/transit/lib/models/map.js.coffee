class Transit.Models.Map extends Backbone.Model
  urlRoot: '/api/otp/metadata'

  defaults:
    api_url: 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    attribution: 'Map data &copy;
    <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
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
      @set marker_name, new L.Marker(point, clickable: false, draggable: true), silent: true
      # update location after the drag, trigger a drag event on a drag
      marker = @get(marker_name)
      marker.on 'dragstart', =>
        @trigger "drag drag:start drag:start:#{attribute}"
      marker.on 'dragend', =>
        @set(attribute, lat: marker.getLatLng().lat, lon: marker.getLatLng().lng)
        @trigger "drag drag:end drag:end:#{attribute}"
      @map.addLayer(marker)
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

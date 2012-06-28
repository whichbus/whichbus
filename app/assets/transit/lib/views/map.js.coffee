class Transit.Views.Map extends Backbone.View
  el: 'div#map'

  initialize: =>
    api_url = 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    seattle = new L.LatLng(47.62167,-122.349072)
    @map = Transit.map = new L.Map(@el,
      center: seattle
      zoom: 13
      maxZoom: 17
    )
    cloudmade = new L.TileLayer(api_url,
      attribution: 'Map data &copy;
      <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
      <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
      &copy; <a href="http://mapbox.com/">Mapbox</a>'
    )
    @map.attributionControl.setPrefix('')
    @map.addLayer(cloudmade)
    @fetch_bounds()

  fetch_bounds: =>
    # TODO: Move this to the map model.
    $.get '/otp/metadata', (data) =>
      south_west = new L.LatLng(data.lowerLeftLatitude, data.lowerLeftLongitude)
      north_east = new L.LatLng(data.upperRightLatitude, data.upperRightLongitude)
      @map.setMaxBounds(new L.LatLngBounds(south_west, north_east))

  render: =>
    this

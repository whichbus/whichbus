class Transit.Views.Map extends Backbone.View
  el: 'div#map'

  initialize: =>
    api_url = 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    @map = Transit.map = new L.Map(@el,
      maxZoom: 17
    )
    cloudmade = new L.TileLayer(api_url,
      attribution: 'Map data &copy;
      <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
      <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
      Imagery &copy; <a href="http://mapbox.com/">Mapbox</a>',
      maxZoom: 18)
    seattle = new L.LatLng(47.62167,-122.349072)
    @map.setView(seattle, 13).addLayer(cloudmade)
    @fetch_bounds()

  fetch_bounds: =>
    # TODO: Move this to the map model.
    $.get '/otp/metadata', (data) =>
      south_west = new L.LatLng(data.lowerLeftLatitude, data.lowerLeftLongitude)
      north_east = new L.LatLng(data.upperRightLatitude, data.upperRightLongitude)
      @map.setMaxBounds(new L.LatLngBounds(south_west, north_east))

  render: =>
    this

class Bus.Views.Map extends Backbone.View
  el: 'div#map'

  render: =>
    api_url = 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    map = new L.Map(@el)
    cloudmade = new L.TileLayer(api_url,
      attribution: 'Map data &copy;
      <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
      <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
      Imagery &copy; <a href="http://mapbox.com/">Mapbox</a>',
      maxZoom: 18)
    seattle = new L.LatLng(47.62167,-122.349072)
    map.setView(seattle, 13).addLayer(cloudmade)
    
    # route
    points = decodeLine('wzqaHn{tiVAEo@oBk@mBm@mBi@}AEOm@mBm@qB{A}EkAqDQk@o@mBQk@Qg@Sq@qAgEe@wAGUm@oBWw@EQC]@{AaFC?yBAcC?y@?yC?sE?_G?gB?[AiB?]iFDQ?g@@iB?eA?}@?')
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: 'red')
    # zoom the map to the polyline
    map.fitBounds(new L.LatLngBounds(latlngs))
    # add the polyline to the map
    map.addLayer(polyline)
    this

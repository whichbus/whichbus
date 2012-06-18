class Bus.Views.Map extends Backbone.View
  el: 'div#map'


  initialize: =>
    api_url = 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    @map = new L.Map(@el)
    cloudmade = new L.TileLayer(api_url,
      attribution: 'Map data &copy;
      <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
      <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
      Imagery &copy; <a href="http://mapbox.com/">Mapbox</a>',
      maxZoom: 18)
    seattle = new L.LatLng(47.62167,-122.349072)
    @map.setView(seattle, 13).addLayer(cloudmade)

  render: =>
    # route
    points = decodeLine('wzqaHn{tiVAEo@oBk@mBm@mBi@}AEOm@mBm@qB{A}EkAqDQk@o@mBQk@Qg@Sq@qAgEe@wAGUm@oBWw@EQC]@{AaFC?yBAcC?y@?yC?sE?_G?gB?[AiB?]iFDQ?g@@iB?eA?}@?')
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: 'red')
    # zoom the map to the polyline
    @map.fitBounds(new L.LatLngBounds(latlngs))
    # add the polyline to the map
    @map.addLayer(polyline)
    @plan()
    this


  plan: (from, to) =>
    data = {
      arriveBy: false
      time: '2:00 pm'
      ui_date: '6/1/2012'
      mode: 'TRANSIT,WALK'
      optimize: 'QUICK'
      maxWalkDistance: 840
      date: '2012-06-01'
      routerId: ''
      toPlace: '47.618624,-122.320796'
      fromPlace: '47.633202,-122.361823'
    }
    $.get '/otp/plan', data, (response) =>
      console.log response

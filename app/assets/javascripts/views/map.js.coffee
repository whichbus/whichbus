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
    @on 'plan_complete', @draw_route

  render: =>
    # route
    from = new L.Marker(new L.LatLng(47.63320158032844, -122.36168296958942))
    @map.addLayer(from)
    to = new L.Marker(new L.LatLng(47.618624, -122.320796))
    @map.addLayer(to)
    @plan(from, to)
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
    }
    data.fromPlace = "#{from.getLatLng().lat},#{from.getLatLng().lng}"
    data.toPlace = "#{to.getLatLng().lat},#{to.getLatLng().lng}"
    $.get '/otp/plan', data, (response) =>
      @trigger 'plan_complete', response.plan


  draw_route: (plan) =>
    console.log plan
    itinerary = plan.itineraries[0]
    for leg in itinerary.legs
      @draw_polyline(leg.legGeometry.points, if leg.mode == 'BUS' then 'red' else 'black')


  draw_polyline: (points, color) =>
    points = decodeLine(points)
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: color)
    # zoom the map to the polyline
    #@map.fitBounds(new L.LatLngBounds(latlngs))
    # add the polyline to the map
    @map.addLayer(polyline)


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
    @marker_icon = L.Icon.extend(
      iconUrl: 'assets/marker.png'
      shadowUrl: 'assets/marker-shadow.png')
    @from = new L.Marker(
      new L.LatLng(47.63320158032844, -122.36168296958942),
      icon: new @marker_icon, clickable: false, draggable: true)
    @to = new L.Marker(
      new L.LatLng(47.618624, -122.320796),
      icon: new @marker_icon, clickable: false, draggable: true)
    @from.on 'dragend', @plan
    @to.on 'dragend', @plan
    @_polylines = []

  render: =>
    # route

    @map.addLayer(@from)
    @map.addLayer(@to)
    #@plan(from, to)
    this


  plan: =>
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
    data.fromPlace = "#{@from.getLatLng().lat},#{@from.getLatLng().lng}"
    data.toPlace = "#{@to.getLatLng().lat},#{@to.getLatLng().lng}"
    $.get '/otp/plan', data, (response) =>
      @trigger 'plan_complete', response.plan


  clean_up: =>
    for polyline in @_polylines
      @map.removeLayer(polyline)
    @_polylines = []

  draw_route: (plan) =>
    @clean_up()
    console.log plan
    itinerary = plan.itineraries[0]
    for leg in itinerary.legs
      @draw_polyline(leg.legGeometry.points, if leg.mode == 'BUS' then 'red' else 'black')


  draw_polyline: (points, color) =>
    points = decodeLine(points)
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: color)
    @_polylines.push polyline
    # zoom the map to the polyline
    #@map.fitBounds(new L.LatLngBounds(latlngs))
    # add the polyline to the map
    @map.addLayer(polyline)


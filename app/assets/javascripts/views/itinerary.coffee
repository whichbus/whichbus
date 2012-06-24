class Transit.Views.Itinerary extends Backbone.View
  initialize: =>
    @map = Transit.map
    @marker_icon = L.Icon.extend
      iconUrl: 'assets/marker.png'
      shadowUrl: 'assets/marker-shadow.png'
    @from = new L.Marker(
      new L.LatLng(@model.get('from').lat, @model.get('from').lon),
      icon: new @marker_icon, clickable: false, draggable: true)
    @to = new L.Marker(
      new L.LatLng(@model.get('to').lat, @model.get('to').lon),
      icon: new @marker_icon, clickable: false, draggable: true)
    @from.on 'dragstart', @clean_up
    @to.on 'dragstart', @clean_up
    @from.on 'dragend', @update_plan
    @to.on 'dragend', @update_plan
    Transit.events.on 'plan:complete', @render
    @plan_route = new L.LayerGroup()

  render: =>
    @map.addLayer(@from)
    @map.addLayer(@to)
    @render_map()
    this

  update_plan: =>
    @model.set
      date: new Date()
      from: lat: @from.getLatLng().lat, lon: @from.getLatLng().lng
      to: lat: @to.getLatLng().lat, lon: @to.getLatLng().lng
    Transit.plan.fetch
      success: (plan) -> Transit.events.trigger 'plan:complete', plan
      error: (model, message) -> console.log message

  clean_up: =>
    Transit.events.trigger 'plan:clear'
    @plan_route.clearLayers()


  render_map: =>
    @clean_up()
    itinerary = Transit.plan.get('itineraries').first()
    colors = {'BUS': 'blue', 'WALK': 'black'}
    for leg in itinerary.get('legs')
      @draw_polyline(leg.legGeometry.points, colors[leg.mode] ? 'red')
    @map.addLayer(@plan_route)


  draw_polyline: (points, color) =>
    points = decodeLine(points)
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: color)
    @plan_route.addLayer(polyline)
    # zoom the map to the polyline
    #@map.fitBounds(new L.LatLngBounds(latlngs))

class Transit.Views.Plan extends Backbone.View
  template: JST['plan']
  className: 'plan'

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
    @map.addLayer(@from)
    @map.addLayer(@to)
    @from.on 'dragstart', @clean_up
    @to.on 'dragstart', @clean_up
    @from.on 'dragend', @update_plan
    @to.on 'dragend', @update_plan
    Transit.events.on 'plan:complete', @render_map
    Transit.events.on 'plan:complete', @add_segments
    @model.on 'change:from change:to fetch', @fetch_plan
    @model.on 'change:from change:to', @update_markers
    @plan_route = new L.LayerGroup()

  render: =>
    $(@el).html(@template())
    this

  update_plan: =>
    @model.set
      date: new Date()
      from: lat: @from.getLatLng().lat, lon: @from.getLatLng().lng
      to: lat: @to.getLatLng().lat, lon: @to.getLatLng().lng


  update_markers: =>
    @from.setLatLng(new L.LatLng(@model.get('from').lat, @model.get('from').lon))
    @to.setLatLng(new L.LatLng(@model.get('to').lat, @model.get('to').lon))


  fetch_plan: =>
    @model.fetch
      success: (plan) -> Transit.events.trigger 'plan:complete', plan
      error: (model, message) -> console.log message


  clean_up: =>
    @render()
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


  add_segments: (plan) =>
    segments = plan.get('itineraries').first().get('legs')
    first_transit_leg = _.find segments, (segment) -> segment.mode != 'WALK'
    for leg in segments
      if first_transit_leg.tripId == leg.tripId
        real_time = new Transit.Models.RealTime(segment: first_transit_leg)
        real_time.fetch
          success: (data) =>
            @$('.real-time').html(data.readable_delta())
      view = new Transit.Views.Segment(segment: leg)
      @$('.segments').append(view.render().el)
      @$('.progress').hide()

class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']
  className: 'plan'

  initialize: =>
    @map = Transit.map
    @from = new L.Marker(
      new L.LatLng(@model.get('from').lat, @model.get('from').lon),
      clickable: false, draggable: true)
    @to = new L.Marker(
      new L.LatLng(@model.get('to').lat, @model.get('to').lon),
      clickable: false, draggable: true)
    @map.addLayer(@from)
    @map.addLayer(@to)
    @from.on 'dragstart', @clean_up
    @to.on 'dragstart', @clean_up
    @from.on 'dragend', @update_plan
    @to.on 'dragend', @update_plan
    Transit.events.on 'plan:complete', @render_map
    Transit.events.on 'plan:complete', @add_segments
    @model.on 'geocode fetch', @fetch_plan
    @model.on 'change:from change:to', @update_markers
    Transit.events.on 'plan:complete', @fit_bounds
    @plan_route = new L.LayerGroup()

  render: =>
    $(@el).html(@template())
    this

  update_plan: =>
    @model.set
      date: new Date()
      from: lat: @from.getLatLng().lat, lon: @from.getLatLng().lng
      to: lat: @to.getLatLng().lat, lon: @to.getLatLng().lng
      fit_bounds: false
    @model.trigger 'fetch'


  update_markers: =>
    @from.setLatLng(new L.LatLng(@model.get('from').lat, @model.get('from').lon))
    @to.setLatLng(new L.LatLng(@model.get('to').lat, @model.get('to').lon))


  fetch_plan: =>
    @clean_up()
    @model.fetch
      success: (plan) -> Transit.events.trigger 'plan:complete', plan
      error: (model, message) =>
        @$('.progress').hide()
        @$('.alert').html(message).show()


  clean_up: =>
    @render()
    @plan_route.clearLayers()


  render_map: =>
    @clean_up()
    itinerary = Transit.plan.get('itineraries').first()
    colors = {'BUS': '#025d8c', 'WALK': 'black'}
    for leg in itinerary.get('legs')
      @draw_polyline(leg.legGeometry.points, colors[leg.mode] ? '#1693a5')
    @map.addLayer(@plan_route)


  draw_polyline: (points, color) =>
    points = decodeLine(points)
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: color, opacity: 0.6, clickable: false)
    @plan_route.addLayer(polyline)


  add_segments: (plan) =>
    segments = plan.get('itineraries').first().get('legs')
    first_transit_leg = _.find segments, (segment) -> segment.mode != 'WALK'
    for leg in segments
      view = new Transit.Views.Segment(segment: leg)
      # show real-time data only for the first bus
      if first_transit_leg?.tripId == leg.tripId
        real_time_view = view
        real_time = new Transit.Models.RealTime(segment: first_transit_leg)
        real_time.fetch
          success: (data) =>
            real_time_view.$('.real-time').html(data.readable_delta())
            if data.delta_in_minutes()?
                real_time_view.$('.real-time').addClass(data.delta_class()).show()
      @$('.segments').append(view.render().el)
      @$('.progress').hide()


  fit_bounds: =>
    if @model.get('fit_bounds')
      point = (latlng) -> new L.LatLng(latlng[0], latlng[1])
      points = (leg) ->_.map decodeLine(leg.legGeometry.points), point
      legs = _.map @model.get('itineraries').first().get('legs'), points
      bounds = new L.LatLngBounds(_.reduce legs, (a, b) -> a.concat(b))
      @map.fitBounds(bounds)
    @model.set { 'fit_bounds': @model.defaults.fit_bounds? }, { silent: true }

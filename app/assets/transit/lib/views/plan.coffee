class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']
  className: 'plan'

  events:
    'click .go-back': 'go_to_splash'

  initialize: =>
    @map = Transit.map
    @map.from = new L.Marker(
      new L.LatLng(@model.get('from').lat, @model.get('from').lon),
      clickable: false, draggable: true)
    @map.to = new L.Marker(
      new L.LatLng(@model.get('to').lat, @model.get('to').lon),
      clickable: false, draggable: true)
    @map.addLayer(@map.from)
    @map.addLayer(@map.to)
    @map.from.on 'dragend', @update_plan
    @map.to.on 'dragend', @update_plan
    Transit.events.on 'plan:complete', @add_itineraries
    @model.on 'geocode geolocate fetch', @fetch_plan
    @model.on 'change:from change:to', @update_markers
    Transit.events.on 'plan:complete', @fit_bounds

  render: =>
    $(@el).html(@template())
    this

  update_plan: =>
    @model.set
      date: new Date()
      from: lat: @map.from.getLatLng().lat, lon: @map.from.getLatLng().lng
      to: lat: @map.to.getLatLng().lat, lon: @map.to.getLatLng().lng
      fit_bounds: false
    @model.trigger 'fetch'


  update_markers: =>
    @map.from.setLatLng(new L.LatLng(@model.get('from').lat, @model.get('from').lon))
    @map.to.setLatLng(new L.LatLng(@model.get('to').lat, @model.get('to').lon))


  fetch_plan: =>
    @render()
    @model.fetch
      success: (plan) -> Transit.events.trigger 'plan:complete', plan
      error: (model, message) =>
        @$('.progress').hide()
        @$('.alert').html(message).show()




  add_itineraries: (plan) =>
    window.plan = plan
    console.log plan
    plan.get('itineraries').each (trip, index) =>
      trip.set('index', index + 1)
      console.log trip
      view = new Transit.Views.Itinerary
        model: trip
        index: index
      if Transit.plan.get('itineraries').first() == trip
        view.render_map()
      @$('.itineraries').append(view.render().el)
      @$('.progress').hide()

  add_segments: (plan) =>
    console.log 'segments'
    console.log plan
    for leg in plan.get('legs')
      view = new Transit.Views.Segment(segment: leg)
      # show real-time data only for the first bus
      if leg.mode == 'BUS'
        real_time = new Transit.Models.RealTime
          agency: leg.from.stopId.agencyId
          code: leg.from.stopId.id
          trip: leg.tripId
          view: view
        real_time.fetch
          success: (data) =>
            console.log "#{data.get('agency')}/#{data.get('code')} prediction: #{data.readable_delta() or 'unavailable'}"
            data.get('view').$('.real-time').html(data.readable_delta())
            if data.delta_in_minutes()?
                data.get('view').$('.real-time').addClass(data.delta_class()).show()
      @$('.itineraries').append(view.render().el)
      @$('.progress').hide()


  fit_bounds: =>
    if @model.get('fit_bounds')
      point = (latlng) -> new L.LatLng(latlng[0], latlng[1])
      points = (leg) ->_.map decodeLine(leg.legGeometry.points), point
      legs = _.map @model.get('itineraries').first().get('legs'), points
      bounds = new L.LatLngBounds(_.reduce legs, (a, b) -> a.concat(b))
      @map.fitBounds(bounds)
    @model.set { 'fit_bounds': @model.defaults.fit_bounds? }, { silent: true }

  go_to_splash: (event) =>
    # TODO: Place this to the topbar.
    # FIXME: There are a few zombie events bound to the model, need to unbind them.
    @remove()
    @off()
    event.preventDefault()
    Transit.router.navigate '', trigger: true

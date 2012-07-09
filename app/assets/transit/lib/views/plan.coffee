class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']
  className: 'plan'

  events:
    'click .go-back': 'go_to_splash'

  initialize: =>
    @map = Transit.map

    @map.on 'drag:end', @update_plan

    Transit.events.on 'plan:complete', @add_itineraries
    @model.on 'geocode geolocate fetch', @fetch_plan
    @model.on 'change:from change:to', @update_markers
    Transit.events.on 'plan:complete', @fit_bounds
    @model.geocode_from_to(@options.from, @options.to)

  render: =>
    $(@el).html(@template())
    this

  update_plan: =>
    @model.set
      date: new Date()
      from: @map.get('from')
      to: @map.get('to')
    @map.set fit_bounds: false, { silent: true }
    @model.trigger 'fetch'


  update_markers: =>
    @map.set
      from: _.pick(@model.get('from'), 'lat', 'lon')
      to: _.pick(@model.get('to'), 'lat', 'lon')



  fetch_plan: =>
    @render()
    @model.fetch
      success: (plan) ->
        Transit.events.trigger 'plan:complete', plan
      error: (model, message) =>
        @$('.progress').hide()
        @$('.alert').html(message).show()




  add_itineraries: (plan) =>
    window.plan = plan
    console.log plan
    Transit.setTitle("#{plan.get('from').name} to #{plan.get('to').name}")
    plan.get('itineraries').each (trip, index) =>
      trip.set('index', index + 1)
      console.log trip
      view = new Transit.Views.Itinerary
        model: trip
        index: index
      # only render the first itinerary, disable mouse over events for it
      if Transit.plan.get('itineraries').first() == trip
        view.undelegateEvents()
        view.render_map()
      @$('.itineraries').append(view.render().el)
      @$('.progress').hide()


  fit_bounds: =>
    if @map.get('fit_bounds')
      point = (latlng) -> new L.LatLng(latlng[0], latlng[1])
      points = (leg) -> _.map decodeLine(leg.legGeometry.points), point
      legs = _.map @model.get('itineraries').first().get('legs'), points
      bounds = new L.LatLngBounds(_.reduce legs, (a, b) -> a.concat(b))
      @map.leaflet.fitBounds(bounds)
    @map.set 'fit_bounds': @map.defaults.fit_bounds?, { silent: true }

  go_to_splash: (event) =>
    # TODO: Place this to the topbar.
    # FIXME: There are a few zombie events bound to the model, need to unbind them.
    @remove()
    @off()
    event.preventDefault()
    Transit.router.navigate '', trigger: true

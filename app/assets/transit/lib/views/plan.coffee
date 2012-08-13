class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']
  className: 'plan'

  events:
    'click .go-back': 'go_to_splash'
    'click header h3': 'display_trip_options'
    'submit .trip-options': 'change_trip_options'

  initialize: =>
    @map = Transit.map
    @map.on 'drag:end', @update_plan
    Transit.events.on 'plan:complete', @add_itineraries
    @model.on 'geocode geolocate fetch', @fetch_plan
    @model.on 'change:from change:to', @update_markers
    @model.on 'geocode:error', @geocode_error
    # Transit.events.on 'plan:complete', @fit_bounds
    Transit.map.on 'complete', =>
      @model.geocode_from_to(@options.from, @options.to)

  render: =>
    $(@el).html(@template(plan: @model))
    this

  update_plan: =>
    console.log "UPDATING PLAN..."
    @model.set
      from: @map.get('from')
      to: @map.get('to')
    @model.trigger 'fetch'

  display_trip_options: =>
    @$('.trip-options').slideToggle()

  change_trip_options: (event) =>
    event.preventDefault()
    date = $('input[name="trip_date"]').val()
    time = $('input[name="trip_time"]').val()
    @model.set({
      date: new Date(Date.parse("#{date} #{time}")),
      arrive_by: if $('select[name="arrive_or_depart"]').val() == 'by' then true else false
    }, { silent: true })
    # TODO: See if this can be bound to a model date change event.
    @model.trigger 'fetch'

  update_markers: =>
    @map.set
      from: _.pick(@model.get('from'), 'lat', 'lon')
      to: _.pick(@model.get('to'), 'lat', 'lon')


  geocode_error: (message) =>
    @$('.progress').hide()
    Transit.errorMessage("Sorry, don't know that place.", message)


  fetch_plan: =>
    @render()
    @model.fetch
      success: (plan) ->
        Transit.events.trigger 'plan:complete', plan
      error: (model, message) =>
        @$('.progress').hide()
        Transit.errorMessage('Whoops, something went wrong!', message)


  add_itineraries: (plan) =>
    window.plan = plan
    console.log plan
    @$('.subnav h3').text("#{plan.get('from').name} to #{plan.get('to').name}")
    @$('.progress').hide()
    @$('.itineraries').html('')
    plan.get('itineraries').each (trip, index) =>
      trip.set('index', index + 1)
      console.log trip
      view = new Transit.Views.Itinerary
        model: trip
        index: index
      @$('.itineraries').append(view.render().el)
      # only render the first itinerary, disable mouse over events for it
      if index == 0
        view.undelegateEvents()
        view.render_map()
    @fit_bounds()


  fit_bounds: =>
    console.log "fitting bounds..."
    if @map.get('fit_bounds')
      point = (latlng) -> new G.LatLng(latlng[0], latlng[1])
      points = (leg) -> google.maps.geometry.encoding.decodePath(leg.legGeometry.points)
      legs = _.map @model.get('itineraries').first().get('legs'), points
      bounds = new G.LatLngBounds(_.reduce legs, (a, b) -> a.concat(b))
      @map.map.fitBounds(bounds)
    @map.set 'fit_bounds': @map.defaults.fit_bounds?, { silent: true }

  go_to_splash: (event) =>
    # TODO: Place this to the topbar.
    # FIXME: There are a few zombie events bound to the model, need to unbind them.
    @remove()
    @off()
    event.preventDefault()
    Transit.router.navigate '', trigger: true

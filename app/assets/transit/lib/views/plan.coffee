class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']
  # el: "#navigation"
  # tagName: 'div'
  className: 'plan'

  events:
    'click .go-back': 'go_to_splash'
    'click header h3': 'display_trip_options'
    'submit .trip-options': 'change_trip_options'

  initialize: =>
    @map = Transit.map
    @map.on 'drag:end', @update_plan

    @model.on 'geocode geolocate fetch', @fetch_plan
    @model.on 'geocode:error', @geocode_error

    # add markers and geocode locations once the map is finished.
    # this event is triggered after loading OTP coverage boundaries which is used to bias geocoding results.
    Transit.map.on 'complete', =>
      # create from/to markers, position will be updated later
      Transit.map.addMarker 'from', 'Starting Point', new G.LatLng(), Transit.GMarkers.Start 
      Transit.map.addMarker 'to', 'Ending Point', new G.LatLng(), Transit.GMarkers.End
      # begin the geocoding process!
      @model.geocode_from_to(@options.from, @options.to)

  render: =>
    $(@el).html(@template(plan: @model))
    this

  # update the plan when markers are dragged
  update_plan: =>
    console.log "UPDATING PLAN..."
    # set the model from/to locations from the marker positions
    @model.set
      from: @map.get('from').position.toHash()
      to: @map.get('to').position.toHash()
    # then load the new plan
    @model.trigger 'fetch'

  fetch_plan: =>
    @render()
    # move the from/to markers to geocoded locations
    Transit.map.moveMarker 'from', @model.get('from')
    Transit.map.moveMarker 'to', @model.get('to')
    # fetch the new plan from OTP
    @model.fetch
      success: @add_itineraries
      error: (model, message) =>
        @$('.progress').hide()
        Transit.errorMessage('Whoops, something went wrong!', message)

  geocode_error: (message) =>
    @$('.progress').hide()
    Transit.errorMessage("Sorry, don't know that place.", message)


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


  add_itineraries: (plan) =>
    # reset UI, set title of directions
    @$('.subnav h3').text("#{plan.get('from').name} to #{plan.get('to').name}")
    @$('.progress').hide()
    @$('.itineraries').html('')
    plan.get('itineraries').each (trip, index) =>
      trip.set('index', index + 1)
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
    if @map.get('fit_bounds')
      bounds = new google.maps.LatLngBounds()
      for leg in @model.get('itineraries').first().get('legs')
        for point in google.maps.geometry.encoding.decodePath(leg.legGeometry.points)
          bounds.extend(point)
      @map.map.fitBounds(bounds)
    @map.set 'fit_bounds': @map.defaults.fit_bounds?, { silent: true }

  go_to_splash: (event) =>
    # TODO: Place this to the topbar.
    # FIXME: There are a few zombie events bound to the model, need to unbind them.
    @remove()
    @off()
    event.preventDefault()
    Transit.router.navigate '', trigger: true

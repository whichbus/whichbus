class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']
  # el: "#navigation"
  # tagName: 'div'
  className: 'plan'

  events:
    'click .go-back': 'go_to_splash'
    'click header.options': 'display_trip_options'
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
    @$('#options').tooltip placement: 'bottom' unless $.browser.mobile
    @$('#options').popout
      parent: @$('a.popout')
      title: 'customize journey'
      content: JST['templates/partials/options']
    this

  # update the plan when markers are dragged
  update_plan: =>
    console.log "UPDATING PLAN..."
    # clean up the existing views when markers are dragged
    view.clean_up(true) for view in @views
    
    # set the model from/to locations from the marker positions
    @model.set
      from: @map.get('from').position.toHash()
      to: @map.get('to').position.toHash()
    # update the url and history with new locations
    from_url = @map.get('from').position.toUrlValue()
    to_url = @map.get('to').position.toUrlValue()
    Transit.router.navigate "plan/#{from_url}/#{to_url}"
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
    @$('#tripOptions').slideToggle()
    console.log 'showing popover'

  change_trip_options: (event) =>
    event.preventDefault()
    date = $('input[name="trip_date"]').val()
    time = $('input[name="trip_time"]').val()
    @model.set({
      date: Transit.parse_date("#{date} #{time}"),
      arrive_by: if $('input[name="arrive_or_depart"]:checked').val() == 'by' then true else false
    }, { silent: true })
    # TODO: See if this can be bound to a model date change event.
    @model.trigger 'fetch'

  reset: =>
    @$('.progress').hide()
    @$('.itineraries').html('')
    Transit.errorMessage(null)  # clear the error message

  add_itineraries: (plan) =>
    # reset UI, set title of directions
    console.log "Plan completed", plan
    @reset()
    Transit.setTitleHTML(HTML.icon('heart', 'favorite'), "#{plan.get('from').name} to #{plan.get('to').name}")
    # @$('.subnav h3').text("#{plan.get('from').name} to #{plan.get('to').name}")
    index = 0
    # store the views in a local variable so we can clean them up when markers are dragged
    @views = plan.get('itineraries').map (trip) ->
      view = new Transit.Views.Itinerary
        model: trip
        index: ++index
      @$('.itineraries').append(view.render().el)
      # automatically show the first itinerary
      view.render_map().toggle() if index == 1
      view
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

class Transit.Views.Plan extends Backbone.View
  template: JST['templates/plan']

  className: 'plan'

  events:
    'click .go-back': 'go_to_splash'
    'click header.options': 'display_trip_options'
    'click .btn.cancel': 'display_trip_options'
    'submit form.options': 'change_trip_options'
    'click .btn.up': 'increaseTime'
    'click .btn.down': 'decreaseTime'
    'blur input.time': 'validateTime'
    'submit form.update': 'update_plan'

  initialize: =>
    @map = Transit.map
    @map.on 'drag:end', @drag_plan

    @model.on 'geocode geolocate', @fetch_plan
    @model.on 'geocode:error', @geocode_error
    @model.on 'plan:timeout', @timeout_warn
    Transit.events.on 'geocode:fail', @geocode_fail

    # add markers and geocode locations once the map is finished.
    # this event is triggered after loading OTP coverage boundaries which is used to bias geocoding results.
    Transit.map.on 'complete', =>
      # create from/to markers, position will be updated later
      Transit.map.addMarker 'from', 'Starting Point', Transit.map.latlng(), Transit.Markers.Start, true
      Transit.map.addMarker 'to', 'Ending Point', Transit.map.latlng(), Transit.Markers.End, true
      # begin the geocoding process!
      @model.geocode_from_to(@options.from, @options.to)

  favorite: ->
    name: "#{Transit.unescape @options.from} &rarr; #{Transit.unescape @options.to}"
    type: 'plan'
    url: "plan/#{@options.from}/#{@options.to}"

  render: =>
    $(@el).html(@template(plan: @model))
    @$('#options').tooltip placement: 'bottom' unless $.browser.mobile
    # @$('#options').popout
    #   params: plan: @model
    this

  # update the plan when markers are dragged
  drag_plan: =>
    # set the model from/to locations from the marker positions
    @model.set
      from: @map.get('from').position.toHash()
      to: @map.get('to').position.toHash(),
    { silent: true }
    # update the url and history with new locations
    from_url = @map.get('from').position.toUrlValue()
    to_url = @map.get('to').position.toUrlValue()
    # update the URL but don't trigger, purely cosmetic :)
    Transit.router.navigate "plan/#{from_url}/#{to_url}"
    # then load the new plan by hand
    @fetch_plan()

  # updates plan from geocode fail form
  update_plan: (evt) ->
    evt.preventDefault()
    # update endpoints using form or URL params (from router)
    from = $('#from_query').val() or Transit.unescape @options.from
    to = $('#to_query').val() or Transit.unescape @options.to
    # navigate to new plan URL and trigger reload
    @remove_itineraries()
    @remove()
    Transit.router.navigate "plan/#{from}/#{to}", true

    # @fetch_plan()

  fetch_plan: =>
    @render()
    # remove old itineraries from the map before fetching new ones
    @remove_itineraries()
    # move the from/to markers to geocoded locations
    Transit.map.moveMarker 'from', @model.get('from')
    Transit.map.moveMarker 'to', @model.get('to')
    # fetch the new plan from OTP
    @model.fetch
      success: @add_itineraries
      error: (model, message) =>
        @$('.progress').hide()
        Transit.errorMessage('Whoops, something went wrong!', message)

  geocode_error: (message, location) =>
    @$('.progress').hide()
    # message += "<br><a href=\"/?from=#{location.from}&to=#{location.to}\">Go home and try another address?</a>"
    Transit.errorMessage("Sorry, don't know that place.", JST['templates/partials/geocode-fail']( 
      showFrom: location.from
      showTo: location.to
      message: message
    ))

  geocode_fail: =>
    @$('.progress').hide()
    Transit.errorMessage "Unable to Locate You!", JST['templates/partials/geocode-fail']( 
      showFrom: @options.from is 'here'
      showTo: @options.to is 'here' 
      message: Transit.Errors.GeolocateFail 
    )

  timeout_warn: (message) =>
    # request taking a while, give 'em a nice message with a link home
    Transit.errorMessage("This is taking a long time..."
      HTML.span '', "We're having some trouble planning your trip right now. But it doesn't have to be like this.<br/><br/>",
        HTML.link '/', '', 'Go home and try again?')

  display_trip_options: =>
    @$('form.options').slideToggle('fast')

  change_trip_options: (event) =>
    event.preventDefault()
    date = $('input[name="trip_date"]').val()
    time = $('input[name="trip_time"]').val()
    modes = @$('.mode .btn.active:not([disabled])').map((i, item) -> item.getAttribute 'title').get()
    optimize = @$('.optimize .btn.active:not([disabled])').attr('title')
    console.log "Update plan options:", date, time, modes, optimize

    @model.set
      date: Transit.parse_date("#{date} #{time}"),
      arrive_by: $('input[name="arrive_or_depart"]:checked').val() == 'by'
      modes: modes
      optimize: optimize
    , silent: true
    # TODO: See if this can be bound to a model date change event.
    @model.trigger 'fetch'

  reset: =>
    @$('.progress').hide()
    @remove_itineraries()
    Transit.errorMessage(null)  # clear the error message

  add_itineraries: (plan) =>
    # reset UI, set title of directions
    @reset()
    Transit.setTitleHTML(Transit.Favorites.icon(@favorite().name), "#{plan.get('from').name} to #{plan.get('to').name}")
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

  # remove all itineraries from the map
  remove_itineraries: =>
    if @views? then for view in @views 
      view?.clean_up(true) 
      view.remove()
    @$('#itineraries').html('')

  go_to_splash: (event) =>
    # TODO: Place this to the topbar.
    # FIXME: There are a few zombie events bound to the model, need to unbind them.
    @remove()
    @off()
    event.preventDefault()
    Transit.router.navigate '', trigger: true

  # adds the given amount of minutes to the current time
  increaseTime: (event, amt=30) ->
    [hour, minute] = @parseTime()
    # increase minutes, update hour accordingly
    minute += amt
    if minute >= 60
      hour++
      minute %= 60
    else if minute < 0
      hour--
      minute += 60
    if hour > 23 then hour = 0
    else if hour < 0 then hour = 23
  
    @$('input.time').val "#{HTML.pad(hour, 2)}:#{HTML.pad(minute, 2)}"

  decreaseTime: (event) -> @increaseTime event, -30

  parseTime: ->
    # time can be hh:mmzz, hh:mm zz, hhzz, hh zz, hhz, ...
    time = @$('input.time').val()
    match = /^([012]?[0-9])(?::(\d{2}))?\s*([pa]m?)?$/i.exec time
    if match?
      # if user types pm, make it an afternoon time
      if /p/i.test(match[3]) then match[1] = (match[1] % 12) + 12
      # return array [hr, min] in 24hr format
      [parseInt(match[1]), parseInt(match[2] or 0)]
    else []

  validateTime: ->
    # do not validate times on mobile browsers -- most have special time and calendar entry tools
    return if $.browser.mobile
    [hour, minute] = @parseTime()
    if hour?
      @$('input.time').val "#{HTML.pad(hour, 2)}:#{HTML.pad(minute, 2)}"
    else
      @$('input.time').val(Transit.format_otp_time(new Date()))

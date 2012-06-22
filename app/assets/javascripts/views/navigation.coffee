class Bus.Views.Navigation extends Backbone.View
  template: JST['navigation']
  el: 'div#navigation'

  events:
    'submit': 'plan'
    'click #from-location': 'from_current_location'
    'click #to-location': 'to_current_location'

  initialize: =>
    Bus.events.on 'plan:complete', @add_segments
    Bus.events.on 'plan:clear', @render

  render: =>
    $(@el).html(@template())
    this

  plan: (event) ->
    event.preventDefault()
    from_query = @$('#from_query').val()
    to_query = @$('#to_query').val()
    from_data = {
      format: 'json', q: from_query, countrycodes: 'US'
    }
    to_data = {
      format: 'json', q: to_query, countrycodes: 'US'
    }
    # TODO: This is fugly, need to batch it
    $.get '/nominatim/v1/search', from_data, (from_response) =>
      $.get '/nominatim/v1/search', to_data, (to_response) =>
        Bus.events.trigger 'geocode:complete', from_response[0], to_response[0]


  add_segments: (plan) =>
    @$('.trip').html('')
    for leg in plan.itineraries[0].legs
      view = new Bus.Views.Segment(segment: leg)
      @$('.trip').append(view.render().el)

  # TODO: Use leaflet's map.locate()
  from_current_location: =>
    navigator.geolocation.getCurrentPosition (position) ->
      @$('#from_query').val("#{position.coords.latitude},#{position.coords.longitude}")

  to_current_location: =>
    navigator.geolocation.getCurrentPosition (position) ->
      @$('#to_query').val("#{position.coords.latitude},#{position.coords.longitude}")

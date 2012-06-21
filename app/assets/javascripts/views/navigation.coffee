class Bus.Views.Navigation extends Backbone.View
  template: JST['navigation']
  el: 'div#navigation'

  events:
    'submit': 'plan'

  initialize: =>
    Bus.events.on 'plan:complete', @add_segments

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

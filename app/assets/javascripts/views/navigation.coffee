class Transit.Views.Navigation extends Backbone.View
  template: JST['navigation']
  el: 'div#navigation'

  events:
    'submit': 'geocode'
    'click #from-location': 'from_current_location'
    'click #to-location': 'to_current_location'

  initialize: =>
    @plan_view = new Transit.Views.Plan model: Transit.plan
    Transit.plan.trigger 'fetch'

  render: =>
    $(@el).html(@template()).append(@plan_view.render().el)
    this

  geocode: (event) ->
    event.preventDefault()
    Transit.plan.geocode_from_to @$('#from_query').val(), @$('#to_query').val()


  # TODO: Use leaflet's map.locate()
  from_current_location: =>
    navigator.geolocation.getCurrentPosition (position) ->
      @$('#from_query').val("#{position.coords.latitude},#{position.coords.longitude}")

  to_current_location: =>
    navigator.geolocation.getCurrentPosition (position) ->
      @$('#to_query').val("#{position.coords.latitude},#{position.coords.longitude}")



create_map = ->
  $('body').append('<div id="map"></div>')
  # disable ajax calls to the api
  Transit.Models.GoogleMap.prototype.fetch = sinon.stub()
  Transit.Models.GoogleMap.prototype.addMarker = sinon.stub()
  return new Transit.Models.GoogleMap(el: $('div#map')[0])


create_plan_view = (model) ->
  Transit.Views.Plan.prototype.fetch_plan = sinon.stub()
  Transit.Views.Plan.prototype.update_plan = sinon.stub()
  return new Transit.Views.Plan(model: model, from: 'here', to: 'there')


module 'Plan View Events',
  setup: ->
    Transit.map = create_map()
    @plan = new Transit.Models.Plan(date: new Date())
    sinon.stub(@plan, 'geocode_from_to')
    @plan_view = create_plan_view(@plan)

  teardown: ->
    @plan_view.remove()
    @plan = {}
    Transit.map = {}
    $('#map').remove()


test 'Fetch metadata after creating a plan view.', ->
  ok Transit.map.fetch.calledOnce


test 'Update plan after dragging a marker.', ->
  Transit.map.trigger 'drag:end'
  ok Transit.Views.Plan.prototype.update_plan.calledOnce


test 'Fetch plan after geocode, geolocate and fetch events.', ->
  @plan.trigger 'geocode'
  @plan.trigger 'geolocate'
  @plan.trigger 'fetch'
  equal Transit.Views.Plan.prototype.fetch_plan.callCount, 3


test 'Add start and end markers after the map is completely loaded.', ->
  Transit.map.trigger 'complete'
  ok Transit.map.addMarker.calledTwice, 'called for start and end markers'
  # TODO: the order should't really matter
  ok Transit.map.addMarker.firstCall.calledWith('from'), 'from marker'
  ok Transit.map.addMarker.secondCall.calledWith('to'), 'to marker'


test 'Geocode starting and ending locations once map is loaded.', ->
  Transit.map.trigger 'complete'
  ok @plan.geocode_from_to.calledWith('here', 'there')

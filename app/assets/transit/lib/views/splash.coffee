class Transit.Views.Splash extends Backbone.View
  template: JST['templates/splash']

  'events':
    'submit form': 'create_plan'
    'click #from-location': 'from_current_location'
    'click #to-location': 'to_current_location'

  initialize: =>
    Transit.plan.on 'geocode', @go_to_plan

  render: =>
    $(@el).html(@template())
    this

  create_plan: (event) =>
    event.preventDefault()
    Transit.plan.geocode_from_to @$('#from_query').val(), @$('#to_query').val()

  go_to_plan: =>
    @remove()
    @off()
    from = Transit.plan.get('from')
    to = Transit.plan.get('to')
    Transit.router.navigate "plan/#{from.lat},#{from.lon}/#{to.lat},#{to.lon}", trigger: true

  from_current_location: =>
    # TODO: Refactor this, duplicate of navigation functions
    Transit.plan.current_location @$('#from_query'), 'from'

  to_current_location: =>
    Transit.plan.current_location @$('#to_query'), 'to'

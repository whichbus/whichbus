class Transit.Views.Splash extends Backbone.View
  template: JST['templates/splash']
  id: 'splash'

  'events':
    'submit form': 'go_to_plan'
    'click #from-location': 'from_current_location'
    'click #to-location': 'to_current_location'

  render: =>
    $(@el).html(@template())
    this

  go_to_plan: =>
    event.preventDefault()
    @remove()
    from = @$('#from_query').val()
    to = @$('#to_query').val()
    Transit.router.navigate "plan/#{from}/#{to}", trigger: true

  from_current_location: =>
    Transit.plan.current_location @$('#from_query'), 'from'

  to_current_location: =>
    Transit.plan.current_location @$('#to_query'), 'to'


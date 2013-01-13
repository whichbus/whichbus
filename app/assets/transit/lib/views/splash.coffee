class Transit.Views.Splash extends Backbone.View
  template: JST['templates/splash']
  id: 'splash'
  className: 'container-fluid'

  events:
    'submit form': 'go_to_plan'
    'click #from-location': 'from_current_location'
    'click #to-location': 'to_current_location'
    # 'focusin input.location': 'select_all'

  render: =>
    $(@el).html(@template())
    @fillFromUrl()
    this

  fillFromUrl: =>
    params = Transit.urlParams()
    @$("#from_query").val(params.from)
    @$("#to_query").val(params.to)

  go_to_plan: (event) =>
    event.preventDefault()
    from = @$('#from_query').val().replace(/\s/g, '+')
    to = @$('#to_query').val().replace(/\s/g, '+')
    if (to == null || to.length <= 3)
        @$('#to-location').addClass('btn-danger')
    else
        @$('#to-location').removeClass('btn-danger')
    if (from == null || from.length <=3)
        @$('#from-location').addClass('btn-danger')
    else
        @$('#from-location').removeClass('btn-danger')
    if (to? and from? and to.length > 3 and from.length > 3)
        @remove()
        Transit.router.navigate "plan/#{from}/#{to}", trigger: true

  from_current_location: -> @$("#from_query").val('here')

  to_current_location: -> @$("#to_query").val('here')

  select_all: (evt) -> $(evt.currentTarget).select()

class Transit.Models.Plan extends Backbone.Model
  urlRoot: '/otp/plan'
  defaults:
    itineraries: []
    desired_itineraries: 1

  parse: (plan) =>
    @set
      date: new Date(plan.date)
      from: plan.from
      to: plan.to
      itineraries: new Transit.Collections.Itineraries(plan.itineraries)

  sync: (method, model, options) =>
    if method == 'read'
      $.get @url(), @request(), (response) =>
        # OTP returns status 200 for everything, so handle response manually
        if response.error?
          options.error response.error.msg
        else options.success response.plan
    else options.error 'Plan is read-only.'

  request: =>
    date: @get('date').toDateString()
    time: @get('date').toTimeString()
    fromPlace: "#{@get('from').lat},#{@get('from').lon}"
    toPlace: "#{@get('to').lat},#{@get('to').lon}"
    numItineraries: @get('desired_itineraries')

class Transit.Models.Plan extends Backbone.Model
  urlRoot: '/otp/plan'
  defaults:
    num_itineraries: 1

  

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
    fromPlace: @get('from')
    toPlace: @get('to')
    numItineraries: @get('num_itineraries')


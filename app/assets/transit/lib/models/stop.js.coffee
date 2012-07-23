class Transit.Models.Stop extends Backbone.Model
	urlRoot: '/workshop/stops'

	sync: (method, model, options) =>
		if method == 'read'
			stopUrl = if @get('code')? then "#{@urlRoot}/#{@get('agency')}/#{@get('code')}" else @url()
			$.getJSON stopUrl, (response) =>
				console.log "#{stopUrl} response:", response
				# OTP returns status 200 for everything, so handle response manually
				if response == null
					options.error "The requested stop does not exist."
				else if response.error?
					options.error response.error.msg
				else options.success response
		else options.error 'Stop is read-only.'
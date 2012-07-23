class Transit.Models.Route extends Backbone.Model
	urlRoot: '/workshop/routes'

	sync: (method, model, options) =>
		if method == 'read'
			routeUrl = if @get('code')? then "#{@urlRoot}/#{@get('agency')}/#{@get('code')}" else @url()
			# support OTP IDs as well
			# if(@agency != null)
			# 	routeUrl = 
			$.getJSON routeUrl, (response) =>
				console.log "#{routeUrl} response:", response
				# OTP returns status 200 for everything, so handle response manually
				if response == null
					options.error "The requested route does not exist."
				else if response.error?
					options.error response.error.msg
				else options.success response
		else options.error 'Route is read-only.'
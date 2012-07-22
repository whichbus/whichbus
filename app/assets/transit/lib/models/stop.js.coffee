class Transit.Models.Stop extends Backbone.Model
	agency: null
	code: null
	urlRoot: => '/workshop/stops'

	sync: (method, model, options) =>
		if method == 'read'
			stopUrl = @url()
			if(@agency != null)
				stopUrl = "/workshop/stops/#{@agency}/#{@code}"
			#console.log(stopUrl)
			$.getJSON stopUrl, (response) =>
				# OTP returns status 200 for everything, so handle response manually
				if response == null
					options.error "The requested stop does not exist."
				else if response.error?
					options.error response.error.msg
				else options.success response
		else options.error 'Stop is read-only.'
class Transit.Collections.Stops extends Backbone.Collection
	model: Transit.Models.Stop
	url: =>
		options =
			lat: @models[0].get('lat')
			lon: @models[0].get('lon')
			latSpan: @models[0].get('latSpan')
			lonSpan: @models[0].get('lonSpan')
		"/workshop/stops/nearby?" + _.map(options, (k, v) => "#{v}=#{k}").join("&")

class App.Stop extends Spine.Model
	@configure 'Stop', 'agency', 'name', 'code', 'lat', 'lon', 'direction'
	
	@belongsTo 'routes', 'App.Route'
	@hasMany 'routes', 'App.Route'

	# @extend Spine.Model.Ajax
	# @url '/stop'



	@extend Spine.Model.Local

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.name?.toLowerCase().indexOf(query) isnt -1 or
				item.code?.toLowerCase().indexOf(query) isnt -1

	@fromJSON: (objects) ->
		return unless objects
		if typeof objects is 'string'
			window.obj = objects = JSON.parse(objects)
		# Create objects from array or single object
		if Spine.isArray(objects)
			console.log "creating #{objects.length} Stops"
			(@.create(value) for value in objects)
		else
			console.log "creating Stop"
			@.create(objects)

	@nearby: (lat, lon) ->
		url = OTP_URL + '/stops'
		$.getJSON url, {lat: lat, lon: lon}, (resp) =>
			@fromJSON(resp)

	@fetch: ->
		super
		geolocate (position) =>
			console.log "loading stops at (#{position.coords.latitude},#{position.coords.longitude})"
			@nearby position.coords.latitude, position.coords.longitude

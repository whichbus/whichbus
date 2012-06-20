class App.Stop extends Spine.Model
	@configure 'Stop', 'oba_id', 'agency_code', 'code', 'name', 'lat', 'lon', 'direction', 'stop_type'
	
	@extend Spine.Model.Ajax
	#@extend Spine.Model.Local
	
	@hasMany 'routes', 'App.Route'

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

	# @fetch: ->
	# 	super
	# 	geolocate (position) =>
	# 		console.log "loading stops at (#{position.coords.latitude},#{position.coords.longitude})"
	# 		@nearby position.coords.latitude, position.coords.longitude

	@fetch: (params) ->
		params or= {data: {offset: @last()?.id}}
		super(params)

class App.Route extends Spine.Model
	@configure 'Route', 'shortName', 'description', 'type', 'url', 'polylines'
	# @extend Spine.Model.Ajax
	
	@hasMany 'stops', 'App.Stop'
	@belongsTo 'stop', 'App.Stop'

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.shortName?.toLowerCase().indexOf(query) isnt -1 or
				item.description?.toLowerCase().indexOf(query) isnt -1

	@fromJSON: (objects) ->
		return unless objects
		if typeof objects is 'string'
			objects = JSON.parse(objects)
		# Do some customization...
		# Parse single object or array of objects
		if Spine.isArray(objects)
			(@.create(value) for value in objects)
		else
			@.create(objects)
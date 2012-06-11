class App.Stop extends Spine.Model
	@configure 'Stop', 'name', 'code', 'latitude', 'longitude', 'direction'
	
	@belongsTo 'routes', 'App.Route'
	@hasMany 'routes', 'App.Route'

	# @extend Spine.Model.Ajax
	# @url '/stop'

	# @extend Spine.Model.Local

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.name?.toLowerCase().indexOf(query) isnt -1 or
				item.code?.toLowerCase().indexOf(query) isnt -1

	@fromJSON: (objects) ->
		return unless objects
		if typeof objects is 'string'
			objects = JSON.parse(objects)
		# Create objects from array or single object
		if Spine.isArray(objects)
			(@.create(value) for value in objects)
		else
			@.create(objects)
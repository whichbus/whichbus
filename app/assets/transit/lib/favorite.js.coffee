Transit.Favorites = 
	# the cache object for storing favorites
	storage: Transit.storage_get('favorites')

	# add entry to favorites list
	add: (name, type, url) ->
		if _.isObject(name) then @addUnsafe name else # if value?
			@addUnsafe obj = name: name, type: type, url: url
			obj

	addUnsafe: (object) ->
		console.log "Attempting add:", object
		# only add if object has all the required keys (other keys can be added for specific uses)
		if object? and object.name? and object.type? and object.url?
			@storage.push object
			Transit.storage_set 'favorites', @storage
			console.log "FAVORITE ADD: #{object.name} => #{object.url} (#{object.type})" 
		else
			console.error "FAVORITE FAIL: must have name, type and url"

	remove: (name) ->
		obj = undefined
		# find item with this name if it exists and remove
		if name? 
			index = -1
			_.each @storage, (item, i) -> 
				if item.name == name
					index = i
					obj = item
			@storage.splice index, 1 if index >= 0
		else @storage = []
		Transit.storage_set 'favorites', @storage
		obj

	fetch: (name) -> 
		_.find @storage, (item) -> item.name == name

	exists: (name) -> @fetch(name)?

	# helper for the heart icon with correct active state
	icon: (name) ->
		HTML.icon('heart', "favorite #{if @exists(name) then 'active' else ''}")

	# groups favorites by type for easy display
	groups: -> _.groupBy @storage, (item) -> item.type

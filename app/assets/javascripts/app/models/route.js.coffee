class App.Route extends Spine.Model
	@configure 'Route', 'agency_code', 'code', 'name', 'description', 'url', 'color', 'polylines', 'route_type'
	@extend Spine.Model.Ajax
	
	@hasMany 'stops', 'App.Stop'

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.name?.toLowerCase().indexOf(query) isnt -1 or
				item.description?.toLowerCase().indexOf(query) isnt -1
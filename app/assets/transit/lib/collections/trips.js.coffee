class Transit.Collections.Trips extends Backbone.Collection
	model: Transit.Models.Trip
	url: -> 
		# I'm using collections in a weird way, passing params instead of models to the constructor.
		# So cache the params object the first time this method is called and simply reuse it later on.
		@route = @models[0] unless @route?
		if @route.get('oba_id')
			"/workshop/routes/#{@route.get('oba_id')}/trips"
		else if @route.get('code')
			"/workshop/routes/#{@route.get('agency')}/#{@route.get('code')}/trips"
		else
			"/workshop/routes/#{@route.get('id')}/trips"

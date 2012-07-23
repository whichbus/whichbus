class Transit.Collections.Trips extends Backbone.Collection
	model: Transit.Models.Trip
	url: -> 
		# constructor takes a Stop model, loads arrivals for it
		model = @models[0]
		if model.get('code')
			"/workshop/routes/#{model.get('agency')}/#{model.get('code')}/trips"
		else
			"/workshop/routes/#{model.get('id')}/trips"

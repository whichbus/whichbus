class Transit.Collections.Arrivals extends Backbone.Collection
	model: Transit.Models.Arrival
	url: -> 
		# constructor takes a Stop model, loads arrivals for it
		"/workshop/stops/#{@models[0].get('id')}/arrivals"

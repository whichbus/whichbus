class Transit.Collections.Arrivals extends Backbone.Collection
	model: Transit.Models.Arrival
	url: -> 
		# constructor takes a Stop model, loads arrivals for it
		model = @models[0]
		if model.get('code')
			"/workshop/stops/#{model.get('agency')}/#{model.get('code')}/arrivals"
		else
			"/workshop/stops/#{model.get('id')}/arrivals"

class Transit.Views.Map extends Backbone.View
  el: 'div#map'

  initialize: =>
  	if GOOGLE?
    	Transit.map = new Transit.Models.GoogleMap(el: @el)
    else
    	Transit.map = new Transit.Models.Map(el: @el)


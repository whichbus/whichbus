class Transit.Views.MapView extends Backbone.View
  el: 'div#map'

  initialize: =>
  	if GOOGLE?
    	Transit.map = new Transit.Models.GoogleMap(el: @el)
    else
    	Transit.map = new Transit.Models.Map(el: @el)

###
# Flip this switch to toggle which map implementation is used.
###
window.GOOGLE = true

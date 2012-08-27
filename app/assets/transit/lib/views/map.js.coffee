class Transit.Views.Map extends Backbone.View
  el: 'div#map'

  initialize: =>
    Transit.map = new Transit.Models.GoogleMap(el: @el)


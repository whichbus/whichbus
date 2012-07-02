class Transit.Views.Map extends Backbone.View
  el: 'div#map'

  initialize: =>
    Transit.map = new Transit.Models.Map(element: @el)

  render: =>
    this

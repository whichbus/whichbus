class Bus.Views.Map extends Backbone.View
  el: 'div#map'

  render: =>
    map = new L.Map(@el.id)
    this

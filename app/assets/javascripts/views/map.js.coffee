class Transit.Views.Map extends Backbone.View
  el: 'div#map'

  initialize: =>
    api_url = 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    @map = Transit.map = new L.Map(@el)
    cloudmade = new L.TileLayer(api_url,
      attribution: 'Map data &copy;
      <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
      <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
      Imagery &copy; <a href="http://mapbox.com/">Mapbox</a>',
      maxZoom: 18)
    seattle = new L.LatLng(47.62167,-122.349072)
    @map.setView(seattle, 13).addLayer(cloudmade)

    Transit.events.on 'geocode:complete', @update_markers


  render: =>
    itinerary_view = new Transit.Views.Plan model: Transit.plan
    itinerary_view.update_plan()
    this




  update_markers: (from, to) =>
    #@from.setLatLng(new L.LatLng(from.lat, from.lon))
    #@to.setLatLng(new L.LatLng(to.lat, to.lon))
    @plan()

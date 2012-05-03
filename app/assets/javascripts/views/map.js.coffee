class Bus.Views.Map extends Backbone.View
  el: 'div#map'

  render: =>
    api_key = '1b90ae3e92ad47b09ea63954b70f91b8'
    api_url = "http://{s}.tile.cloudmade.com/#{api_key}/997/256/{z}/{x}/{y}.png"
    map = new L.Map(@el.id)
    cloudmade = new L.TileLayer(api_url, {
          attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery &copy; <a href="http://cloudmade.com">CloudMade</a>', maxZoom: 18
    })
    seattle = new L.LatLng(47.62167,-122.349072)
    map.setView(seattle, 13).addLayer(cloudmade)
    this

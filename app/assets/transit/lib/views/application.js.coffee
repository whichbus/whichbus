class Transit.Views.Application extends Backbone.View
  template: JST['templates/index']
  el: 'div#container'

  events:
  	'click .icon.favorite': 'toggleFavorite'

  render: =>
    $(@el).html(@template())
    this

  toggleFavorite: (evt) =>
  	$(evt.currentTarget).toggleClass('active')

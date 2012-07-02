class Transit.Views.Application extends Backbone.View
  template: JST['templates/index']
  el: 'div#container'

  render: =>
    $(@el).html(@template())
    this

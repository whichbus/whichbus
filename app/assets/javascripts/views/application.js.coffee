class Transit.Views.Application extends Backbone.View
  template: JST['index']

  render: =>
    $(@el).html(@template())
    this

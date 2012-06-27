class Transit.Views.Application extends Backbone.View
  template: JST['templates/index']

  render: =>
    $(@el).html(@template())
    this

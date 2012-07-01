class Transit.Views.Splash extends Backbone.View
  template: JST['templates/splash']

  render: =>
    $(@el).html(@template())
    this


class Transit.Views.Application extends Backbone.View
  template: JST['templates/index']
  el: 'div#container'

  events:
    'click .icon.favorite': 'toggleFavorite'
    'click a.btn-route': 'niceNavigate'
    'click a.btn-stop': 'niceNavigate'

  render: =>
    $(@el).html(@template())
    this

  toggleFavorite: (evt) =>
    $(evt.currentTarget).toggleClass('active')

  # gracefully navigates to the route page when a route button is clicked
  # way smoother and faster than standard link behavior!
  niceNavigate: (evt) =>
    evt.preventDefault()
    Transit.router.navigate $(evt.currentTarget).attr('href'), trigger: true
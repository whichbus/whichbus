class Transit.Views.Application extends Backbone.View
  template: JST['templates/index']
  el: 'div#container'

  events:
    'click i.favorite': 'toggleFavorite'
    'click a.btn-route': 'niceNavigate'
    'click a.btn-stop': 'niceNavigate'

  initialize: ->
    # create navbar view and attach its events (already rendered in transit template)
    @navbar = new Transit.Views.Navbar()

  render: =>
    $(@el).html(@template())
    window.scrollTo(0, 1) if $.browser.mobile
    this

  toggleFavorite: (evt) =>
    fav = $(evt.currentTarget)
    fav.toggleClass 'active'
    # add or remove favorite based on active state
    if fav.hasClass 'active'
      Transit.Favorites.add Transit.mainView.favorite()
    else
      Transit.Favorites.remove Transit.mainView.favorite().name


  # gracefully navigates to the route page when a route button is clicked
  # way smoother and faster than standard link behavior!
  niceNavigate: (evt) =>
    evt.preventDefault()
    Transit.router.navigate $(evt.currentTarget).attr('href'), trigger: true

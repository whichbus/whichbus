class Transit.Views.Navbar extends Backbone.View
  # select the navbar after it's been created. use delegateEvents() to attach event handlers.
  el: 'div.navbar'
  # note no render() method because this view is automatically rendered in the template

  events:
    'click #settings-button': 'toggleMenu'
    'click #clearCache': 'clearCache'
    'click #locate': 'locate'

  initialize: ->
    @$('a[title]').tooltip
      placement: 'bottom'
    # @$('#directions').popover
    #   trigger: 'click'
    #   placement: 'bottom'
    #   title: 'The Title'
    #   selector: '#directions-popover'
    @delegateEvents()
    $('#settings-bg').click @toggleMenu

  # toggle settings menu appearance
  toggleMenu: (evt) ->
    $('#settings-bg').toggle()
    $('#settings-menu').toggle()
    $('#settings-button').toggleClass('active')

  # automagically locate the user on the map
  locate: (evt) ->
    # evt.preventDefault()
    console.log Transit.router.view, Transit.router.view.map

  # clear the geocode cache from the settings menu
  clearCache: (evt) ->
    evt.preventDefault()
    Transit.Geocode.cacheClear() if confirm('Are you sure you want to clear your geocache?')

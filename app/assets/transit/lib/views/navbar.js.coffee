class Transit.Views.Navbar extends Backbone.View
  # select the navbar after it's been created. use delegateEvents() to attach event handlers in initialize().
  el: 'div.navbar'
  # note no render() method because this view is automatically rendered in the template

  events:
    'click #settings-button': 'toggleMenu'
    'click #clearCache': 'clearCache'
    'click #locate': 'locate'
    'click a.popout': 'showPopout'

  initialize: ->
    window.navbar = @
    # put tooltips on all navbar links with title attributes
    @$('a[title]').tooltip(placement: 'bottom') unless $.browser.mobile
    # attach event handlers to relevant elements
    @delegateEvents()
    $('#settings-bg').click @toggleMenu

  showPopout: (evt) =>
    evt.preventDefault()
    source = $(evt.currentTarget)
    active = source.hasClass('active')
    # get rid of tooltip and any pre-existing popout
    source.tooltip('hide')
    @popout?.close()
    # if this popout was not already opened...
    unless active
      console.log "popout #{source.attr('id')} opened"
      # make a new popout and append it to body of page
      @popout = new Transit.Views.Popout
        parent: source
        title: source.data('original-title')
        content: JST['templates/partials/' + source.attr('id')]
      $('body').append @popout.render().el

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

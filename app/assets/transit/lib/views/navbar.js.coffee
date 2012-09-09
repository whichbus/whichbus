class Transit.Views.Navbar extends Backbone.View
  # select the navbar after it's been created. use delegateEvents() to attach event handlers.
  el: 'div.navbar'
  # note no render() method because this view is automatically rendered in the template

  events:
    'click #settings-button': 'toggleMenu'
    'click #clearCache': 'clearCache'
    'click #locate': 'locate'
    'click a.popout': 'popout'

  initialize: ->
    @$('a[title]').tooltip
      placement: 'bottom'
    @delegateEvents()
    $('#settings-bg').click @toggleMenu

  popout: (evt) =>
    window.source = $(evt.currentTarget)
    # get rid of tooltip and any pre-existing popout
    source.tooltip('hide')
    @popout?.remove?()
    # if this popout is active then deactivate it
    if source.hasClass('active')
      source.removeClass('active')
    else
      # make a new popout and append it to body of page
      @popout = new Transit.Views.Popout
        parent: source
        title: source.data('original-title')
        partial: JST['templates/partials/' + source.attr('id')]()
      $('body').append @popout.render().el
      # deactive other popouts, make this one active
      @$('a.popout.active').removeClass('active')
      source.addClass('active')

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

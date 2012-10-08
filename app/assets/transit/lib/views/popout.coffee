class Transit.Views.Popout extends Backbone.View
  template: JST['templates/partials/popout']
  className: 'popout'
  # default sizing options
  width: 250
  margin: 10

  events:
    'click .close': 'close'
    'click .search .btn-go': 'loadSearch'
    'click .directions .btn-go': 'loadDirections'
    'click .directions .btn.here': 'geolocate'
    'click .options .btn-go': 'updateTrip'
    'click .favorites li a': 'navigateFavorite'

  render: () ->
    @options.parent.addClass('active')
    # offset from right edge of screen using layout of parent anchor:
    offset = document.width - @options.parent.offset().left - @options.parent.width() / 2
    # actual right edge of popout, constrained by @margin property:
    right = Math.max(@margin, offset - @width / 2)
    # create the popout itself, applying calculated CSS styles
    $(@el).css(
      top: @options.parent.offset().top + @options.parent.height() + @margin
      right: right
      width: @width
    ).html @template(
      left: (offset - @margin) / @width
      title: @options.title
      content: @options.content @params()
    )
    $(@el).addClass(@options.parent.attr('id'))
    # add the arrow to the popout. positioned separately beneath parent
    $(@el).prepend arrow = HTML.div('top-arrow')
    arrow.css('right': offset - @margin) if right <= @margin
    @

  params: ->
    if _.isFunction @options.params then @options.params() else @options.params

  clicked: (evt) ->
    evt.preventDefault()
    console.log "clicked!", evt

  # correctly close this popout and remove active class from parent.
  # returns true if popout was actually closed.
  close: ->
    open = @options.parent.hasClass('active')
    @options.parent.removeClass('active')
    @remove()
    open

  loadDirections: (evt) ->
    evt.preventDefault()
    console.log 'loading directions...'
    @resetForm()
    form = @$('form')
    start = form.find('input[name=from]')
    end = form.find('input[name=to]')
    # ensure fields are not empty before navigating
    if start.val().length < 3
      start.focus().parent().addClass 'error'
    else if end.val().length < 3
      end.focus().parent().addClass 'error'
    else
      @close()
      Transit.router.navigate "plan/#{encodeURIComponent start.val()}/#{encodeURIComponent end.val()}", trigger: true

  geolocate: (evt) ->
    evt.preventDefault()
    $(evt.currentTarget).siblings('input').val('here')

  loadSearch: (evt) ->
    evt.preventDefault()
    @resetForm()
    query = @$('form').find('input[name=query]')
    # ensure fields are not empty before navigating
    if query.val().length < 3
      query.focus().parent().addClass 'error'
    else
      @close()
      Transit.router.navigate "search/#{encodeURIComponent query.val()}", trigger: true

  resetForm: ->
    @$('form .control-group').removeClass('error')

  updateTrip: (evt) ->
    evt.preventDefault()
    console.log 'updating trip'
    console.log @params.plan

  navigateFavorite: (evt) ->
    evt.preventDefault()
    Transit.router.navigate $(evt.currentTarget).attr('href'), trigger: true
    @close()

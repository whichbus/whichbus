class Transit.Views.Popout extends Backbone.View
  template: JST['templates/partials/popout']
  className: 'popout'
  # default sizing options
  width: 250
  margin: 10

  events:
    'click .btn': 'clicked'
    'click .close': 'close'

  render: () ->
    @options.parent.addClass('active')
    # offset from right edge of screen using layout of parent anchor:
    offset = document.width - @options.parent.offset().left - @options.parent.width() / 2
    # actual right edge of popout, constrained by @margin property:
    right = Math.max(@margin, offset - @width / 2)
    # create the popout itself, applying calculated CSS styles
    $(@el).css(right: right, width: @width).html @template(
      left: (offset - @margin) / @width
      title: @options.title
      content: @options.partial
    )
    # $(@el).addClass(@options.parent.attr('id'))
    # add the arrow to the popout. positioned separately beneath parent
    $(@el).prepend arrow = HTML.div('top-arrow')
    arrow.css('right': offset - @margin) if right <= @margin
    @

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
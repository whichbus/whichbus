class Transit.Views.Popout extends Backbone.View
  template: JST['templates/partials/popout']
  className: 'popout'
  width: 250

  events:
    'click': 'clicked'

  render: () ->
    window.pt = @options.parent
    offset = document.width - @options.parent.offset().left 
    right = Math.max(10, offset - @width / 2 - @options.parent.width() / 2)
    # TODO - position arrow correctly when popout is pressed up against edge of screen
    $(@el).css('right', right).css('width', @width).html @template(
      title: @options.title
      content: @options.partial
    )
    @

  clicked: (evt) ->
    evt.preventDefault()
    console.log "clicked!", evt

# class Transit.Views.Directions extends Transit.Views.Popout

  # className: 'popout directions'

  # events:
  #   'click': 'clicked'

  # render: () ->
  #   $(@el).html @partial(@options)
  #   @

  # clicked: (evt) ->
  #   evt.preventDefault()
  #   console.log "clicked!", evt

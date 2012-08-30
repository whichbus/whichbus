class Transit.Views.Modal extends Backbone.View
  # renders a Bootstrap modal dialog. don't forget to set the template before rendering!
  tagName: 'div'
  className: 'modal'

  # we're expecting the modal to contain a bunch of buttons that close the modal when clicked
  events:
    'click .btn': 'handleClick'

  render: ->
    $(@el).html(@template(options: @options)).modal('show')
    console.error 'Provide a template for the modal before rendering!' unless @template?

  handleClick: (event) ->
    event.preventDefault()
    # call the success callback if present
    if @success? then @success $(event.toElement)
    # close the modal
    $(@el).modal 'hide'

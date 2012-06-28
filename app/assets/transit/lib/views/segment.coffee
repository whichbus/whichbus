class Transit.Views.Segment extends Backbone.View
  walk_template: JST['templates/segments/walk']
  bus_template: JST['templates/segments/bus']
  tagName: 'li'
  className: 'segment'

  render: =>
    template = if @options.segment.mode == 'WALK' then @walk_template else @bus_template
    $(@el).html(template(segment: @options.segment))
    this


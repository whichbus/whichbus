class Bus.Views.Segment extends Backbone.View
  walk_template: JST['segments/walk']
  bus_template: JST['segments/bus']
  tagName: 'li'
  className: 'segment'

  render: =>
    template = if @options.segment.mode == 'WALK' then @walk_template else @bus_template
    $(@el).html(template(segment: @options.segment))
    this


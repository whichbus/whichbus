Transit.parse_date = (input) ->
  parts = input.match(/(\d+)-(\d+)-(\d+) (\d+):(\d+)\s*(pm|am){0,1}/i)
  hours = if parts[6]?.toLowerCase() == 'pm' then parseInt(parts[4]) + 12 else parts[4]
  new Date(parts[1], parts[2]-1, parts[3], hours, parts[5])

Transit.format_time = (input) ->
  date = if input not instanceof Date then new Date(input) else input
  hours = date.getHours() % 12 || 12
  minutes = date.getMinutes()
  padded_minutes = "#{if minutes < 10 then '0' else ''}#{minutes}"
  period = if date.getHours() < 12 then 'am' else 'pm'
  "#{hours}:#{padded_minutes} #{period}"

Transit.format_otp_date = (input) ->
  date = if input not instanceof Date then new Date(input) else input
  month = date.getMonth() + 1
  padded_month = "#{if month < 10 then '0' else ''}#{month}"
  day = date.getDate()
  padded_day = "#{if day < 10 then '0' else ''}#{day}"
  year = date.getFullYear()
  "#{year}-#{padded_month}-#{padded_day}"

Transit.format_otp_time = (input) ->
  date = if input not instanceof Date then new Date(input) else input
  hours = date.getHours()
  zone = if hours > 11 then 'pm' else 'am'
  minutes = date.getMinutes()
  padded_minutes = "#{if minutes < 10 then '0' else ''}#{minutes}"
  "#{hours % 12}:#{padded_minutes} #{zone}"

Transit.format_duration = (seconds, minimize) ->
  # if no second parameter specified then auto-minimize if time > 1 hour
  minimize = seconds > 3600 unless minimize?

  return "NOW!" if seconds < 60 and not minimize
  mins = Math.floor(seconds / 60)
  if mins > 59
    hrs = Math.floor(mins / 60)
    mins = mins % 60
  else hrs = 0

  if hrs > 0 then "#{hrs}#{if minimize then 'h' else ' hours'}, #{mins}#{if minimize then 'm' else ' minutes'}"
  else "#{mins}#{if minimize then 'm' else ' minutes'}"

Transit.format_deviation = (seconds) ->
  minutes = Math.round(seconds / 60)
  if minutes > 0
    "#{minutes} minute#{if minutes > 1 then 's' else ''} early"
  else if minutes < 0
    "#{Math.abs(minutes)} minute#{if minutes < -1 then 's' else ''} late"
  else if minutes == 0 
    'on time'
  else null

Transit.deviation_class = (seconds) ->
  if seconds > 30 then 'early label-success'
  else if seconds > -30 then 'on-time label-info'
  else 'late label-important'

Transit.pad = (num, zeroes) -> (1e10+num+"").slice(-zeroes)

Transit.storage_get = (key) ->
  JSON.parse(localStorage.getItem(key) ? '{}')

Transit.storage_set = (key, value) ->
  localStorage.setItem(key, JSON.stringify(value))

Transit.storage_clear = (key) ->
  localStorage.removeItem key

Transit.setTitleHTML = (contents...) =>
  title = $("#title h3").html('')
  title.append(content) for content in contents

Transit.errorMessage = (title, message) =>
  if title?
    @$('.alert').html(message).prepend($("<strong>").html(title)).show()
  else
    @$('.alert').html('').hide()

Transit.errorPage = (title, message) =>
  console.error "#{title} - #{message}"
  $("#navigation").html(JST['templates/error'](title: title, message: message))

# toggles appearance of the Settings menu via the gear button
Transit.toggleMenu = () =>
  $('#settings-bg').toggle()
  $('#settings-menu').toggle()
  $('#settings-button').toggleClass('active')

Transit.loadDirections = (form) ->
  console.log form, arguments
  from = Transit.escape $(form).siblings('input[name=from]').val()
  to = Transit.escape $(form).siblings('input[name=to]').val()

  # if to.length <= 3 then $('#to-location').addClass('btn-danger')
  # else $$('#to-location').removeClass('btn-danger')
  
  # if from.length <=3 then $('#from-location').addClass('btn-danger')
  # else $('#from-location').removeClass('btn-danger')
  
  if (to? and from? and to.length > 3 and from.length > 3)
      # @remove()
      Transit.router.navigate "plan/#{from}/#{to}", trigger: true

Transit.escape = (string) -> escape string.replace(/\s/g, '+')
Transit.unescape = (string) -> unescape string.replace(/\+/g, ' ')

# Transit.Markers =
#   Start: L.Icon.extend
#     iconSize: new L.Point(33, 35)
#     iconAnchor: new L.Point(11, 35)
#     iconUrl: '<%= image_path("icons/icon-start-location.png") %>'
#     shadowUrl: null
#   End: L.Icon.extend
#     iconSize: new L.Point(33, 35)
#     iconAnchor: new L.Point(11, 35)
#     iconUrl: '<%= image_path("icons/icon-end-location.png") %>'
#     shadowUrl: null
#   Stop: L.Icon.extend
#     iconSize: new L.Point(20, 20)
#     iconAnchor: new L.Point(10, 20)
#     iconUrl: '<%= image_path("icons/icon-busstop.png") %>'
#     shadowUrl: null
#   StopDot: L.Icon.extend
#     iconSize: new L.Point(12, 12)
#     iconAnchor: new L.Point(6, 6)
#     iconUrl: '<%= image_path("icons/bus/dot.png") %>'
#     shadowUrl: null
#   Bus: L.Icon.extend
#     iconSize: new L.Point(20, 20)
#     iconAnchor: new L.Point(10, 20)
#     iconUrl: '<%= image_path("icons/bus/bus.png") %>'
#     shadowUrl: null
#   Walk: L.Icon.extend
#     iconSize: new L.Point(20, 20)
#     iconAnchor: new L.Point(10, 20)
#     iconUrl: '<%= image_path("icons/plan-walking.png") %>'
#     shadowUrl: null
#   # dot markers with arrows for compass direction of stop.
#   # expects empty or N NE E SE S SW W NW
#   StopArrow: _.memoize (direction) ->
#     return Transit.Markers.StopDot if direction.length == 0
#     L.Icon.extend
#       iconSize: new L.Point(16, 16)
#       iconAnchor: new L.Point(8, 8)
#       iconUrl: "<%= image_path('icons/bus/dot-arrow-#{direction}.png') %>"
#       shadowUrl: null

headings = ['N', 'NE','E', 'SE', 'S', 'SW', 'W', 'NW']
Transit.degreesToHeading = (degrees) ->
  headings[Math.round (degrees - 22) / 45]

Transit.GMarkers =
  Start: new G.MarkerImage('<%= image_path("icons/icon-start-location.png") %>', new G.Size(33, 35), new G.Point(0, 0), new G.Point(11, 35))
  End: new G.MarkerImage('<%= image_path("icons/icon-end-location.png") %>', new G.Size(33, 35), new G.Point(0, 0), new G.Point(11, 35))
  Stop: '<%= image_path("icons/icon-busstop.png") %>'
  StopDot: new G.MarkerImage('<%= image_path("icons/bus/dot.png") %>', new G.Size(17, 17), new G.Point(0, 0), new G.Point(6, 6), new G.Size(12, 12))
  Bus: '<%= image_path("icons/icon-busstop.png") %>'

window.HTML = {}
# HTML GENERATORS (jQuery wrappers)
HTML.tag = (tagname, classes, body...) ->
  html = $(tagname).addClass(classes)
  html.append text for text in body
  html
HTML.div = (classes, body...) ->
  HTML.tag "<div>", classes, body...
HTML.span = (classes, body...) ->
  HTML.tag "<span>", classes, body...
HTML.li = (classes, body...) ->
  HTML.tag "<li>", classes, body...
HTML.link = (href, classes, body...) ->
  # if body array is empty then assume classes is body content
  unless body? and body.length > 0
    body = [classes] 
    classes = undefined
  HTML.tag("<a>", classes, body...).attr("href", href)
HTML.btn = (classes, text, href=null) ->
  if href?
    HTML.link href, "btn #{classes}", text
  else
    HTML.span "btn #{classes}", text
HTML.icon = (icon, classes) ->
  HTML.tag '<i>', "icon-#{icon} #{classes}"
# str() function returns outer HTML of tag and children as string
# and enables the HTMLpers to be used in javascript templates through
# eco's raw output tag
$.fn.str = () -> @prop('outerHTML')

# nice little jQuery copyright line
Transit.copyright = HTML.div('copyright',
  HTML.span('copy', '&copy;'), '2012 WhichBus - ',
  HTML.link('/about', 'About'), ' - '
  HTML.link('/about/terms', 'Terms'), ' - ', 
  HTML.link('/about/privacy', '', 'Privacy')
).str()

$.fn.popout = (options) ->
  window.opt = options
  console.log @, options
  @view = options.view
  @.click (event) ->
    event.preventDefault()
    source = $(event.currentTarget)
    active = source.hasClass('active')
    # get rid of tooltip and any pre-existing popout
    source.tooltip('hide')
    @popout?.close()
    # if this popout was not already opened...
    unless active
      console.log "popout #{source.attr('id')} opened"
      # make a new popout and append it to body of page
      defaults = 
        parent: source
        title: source.data('original-title')
        content: JST['templates/partials/' + source.attr('id')]
      @popout = new Transit.Views.Popout _.extend(defaults, options)
      $('body').append @popout.render().el


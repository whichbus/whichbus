# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# BOOM PUT THAT SPINE GOODNESS ALL UP IN THERE
#= require app

window.OTP_URL = 'http://whichbus-api.herokuapp.com' 
#'http://otp.whichb.us:8080/opentripplanner-api-webapp/ws'

window.initData = () ->
	$.getJSON 'teststops.json', (resp) ->
		App.Stop.fromJSON(resp)
	$.getJSON 'testroutes.json', (resp) ->
		App.Route.fromJSON(resp)

# rock some geolocation
yesLocation = (position) ->
	pos = latlng position.coords.latitude, position.coords.longitude
	@userPosition = markerOptions({title: "Your Location", position: pos})
	clickMap(pos)
noLocation = (error, callback=null) ->
	msg = "Geolocation Error: "
	switch error.code
		when error.TIMEOUT
			msg += "Timeout"
		when error.POSITION_UNAVAILABLE
			msg += "Position unavailable"
		when error.PERMISSION_DENIED
			msg += "Permission denied"
		when error.UNKNOWN_ERROR
			msg += "Unknown error"
	alertBox "error", msg
	callback(error) if callback?
window.geolocate = (success = yesLocation, fail = null) ->
	navigator.geolocation.getCurrentPosition success, (error) -> noLocation(error, fail)
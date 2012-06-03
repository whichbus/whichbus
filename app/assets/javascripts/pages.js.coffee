# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.initData = () ->
	$.getJSON 'teststops.json', (resp) ->
		App.Stop.fromJSON(resp)
	$.getJSON 'testroutes.json', (resp) ->
		App.Route.fromJSON(resp)
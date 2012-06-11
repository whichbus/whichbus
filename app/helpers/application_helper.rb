module ApplicationHelper
	def agency_item(agency)
		"<li class='agency'><h3>#{link_to agency.name, agency, class: 'btn btn-large btn-info'}</h3></li>"
	end

	def route_item(route)
		"<li class='route'><h3>#{link_to route.name, route, class: 'btn btn-large btn-success'}</h3></li>"
	end

	def stop_item(stop)
		"<li class='stop'><h3>#{link_to stop.name, stop, class: 'btn btn-large btn-warning'}</h3></li>"
	end
end

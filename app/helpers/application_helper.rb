module ApplicationHelper
	def agency_item(agency)
		"<li class='agency'><h2>#{link_to agency.name, agency_path(agency.oba_id), class: 'btn btn-large btn-info'}</h2></li>"
	end

	def route_item(route)
		"<li class='route'><h3>#{link_to route.name, route_path(route.oba_id), class: 'btn btn-large btn-success'}</h3></li>"
	end

	def stop_item(stop)
		"<li class='stop'><h4>#{link_to stop.name, stop_path(stop.oba_id), class: 'btn btn-large btn-warning'}</h4></li>"
	end

	def arrival_item(arrival)
		"<li class='arrival'><h3>
			<span class='btn btn-large btn-success'>#{arrival['routeShortName']}</span>
			#{arrival['tripHeadsign']} at #{Time.at(arrival['predictedArrivalTime'] / 1000).strftime('%r')}
		</li>"
	end

	def wb_route_path(agency_or_id, code=nil)
		str = "/#{agency_or_id}"
		str += "/#{code}" unless code.nil?
	end

	def api_links(item)
		"<small class='api links'>
		<span class='oba id'>OBA: <a class='btn' id='oba_id'>#{item.oba_id}</a></span>
		<span class='otp id'>OTP: " +
			(item.class() == Agency ? '' : "<a class='btn' id='agency'>#{item.agency_code}</a>") +
			"<a class='btn' id='code'>#{item.code}</a>
		</span></small>"
	end
end

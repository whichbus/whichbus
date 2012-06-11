# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open-uri'

@uppercasers = ['P&R', 'NTC', 'CC', 'SCC', 'C.B.D.', 'NE', 'NW', 'SE', 'SW', 'DART', 'LINK', 'TC' ]

@agency_codes = { '1' => 'KCM', 'KMD' => 'KMD', '40' => 'ST'} #'EOS'

# a helper method to load JSON from a url
@request_count = 0
def get_json(url)
	@request_count += 1
	puts "(get #{@request_count}: #{url})"
	JSON.parse(open(url, 'Content-Type' => 'application/json').read)
end

# quick and easy way to query the OneBusAway API
def oba_api(method, id=nil, params=nil)
	@query = params.nil? ? "" : params.map {|key, value| "#{key}=#{value}"}.join('&')
	method += "/" + ERB::Util.url_encode(id) unless id.nil?

	return get_json("http://api.onebusaway.org/api/where/#{method}.json?key=TEST#{@query}")['data']
end

# properly cases all the words in a string. WORK IN PROGRESS
def proper_case(string)
	string.split(' ').map {|w| @uppercasers.include?(w) ? w.upcase : w.capitalize }.join(' ')
end

# add each agency
#   add each route in agency
#     add each stop on route, link them correctly
oba_api("agencies-with-coverage").each do |a|
	data = a['agency']
	# create the agency!
	agency = Agency.create({
			 		oba_id: data['id'],
			 		name: data['name'],
			 		code: @agency_codes[data['id']],
			 		url: data['url'],
					phone: data['phone'],
					timezone: data['timezone'],
					disclaimer: data['disclaimer']
				})
	puts "+agency - #{agency.oba_id}: #{agency.name} (#{agency.code})"

	oba_api("routes-for-agency", agency.oba_id)['list'].each do |rte|
		# create the route record through the agency to build the relationship
		route = agency.routes.find_or_create_by_oba_id(rte['id'],{
								#oba_id: rte['id'],
								agency_code: agency.code,
								code: /_([\w\d]+)/.match(rte['id'])[1],
								name: rte['shortName'].empty? ? proper_case(rte['longName']) : rte['shortName'],
								description: proper_case(rte['description']),
								route_type: rte['type'],
								url: rte['url']
							})
		puts "  +route - #{route.oba_id}: #{route.name} (#{route.code})"

		# load the stops for this route. 
		# but this API contains a lot of data so we'll save it and reference individual parts
		route_data = oba_api("stops-for-route", route.oba_id)

		# the polylines for the route are in one part of the route_data
		route.polylines = route_data['polylines'].map {|line| line['points'] }.join(',')
		route.save!

		# and all the stops are in another!
		route_data['stops'].each do |s|
			stop = Stop.find_or_create_by_oba_id(s['id'], {
											#oba_id: s['id'],
											agency_code: agency.code,
											code: s['code'],
											name: proper_case(s['name']),
											direction: s['direction'].upcase,
											stop_type: s['locationType'],
											lon: s['lon'],
											lat: s['lat']
									})
			route.stops << stop
			puts "    +stop - #{stop.oba_id}: #{stop.name} (#{stop.code})"
		end
	end
end

puts ""
puts "====================="
puts "|| The Grand Totals:"
puts "||  #{Agency.all.count} agencies"
puts "||  #{Route.all.count} routes"
puts "||  #{Stop.all.count} stops"
puts "====================="
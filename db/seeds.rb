# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require 'open-uri'

@startTime = Time.now

###
# QUICK JEFFREY, GET ME THAT JSON FROM THE ONEBUSAWAY API!
###

# a helper method to load JSON from a url (using open-uri)
@request_count = 0
def get_json(url)
	@request_count += 1
	#puts "(get #{@request_count}: #{url})"
	JSON.parse(open(url, 'Content-Type' => 'application/json').read)
end

# quick and easy way to query the OneBusAway API
def oba_api(method, id=nil, params=nil)
	@query = params.nil? ? "" : params.map {|key, value| "#{key}=#{value}"}.join('&')
	method += "/" + ERB::Util.url_encode(id) unless id.nil?

	return get_json("http://api.onebusaway.org/api/where/#{method}.json?key=TEST#{@query}")['data']
end

### 
# PROPER CASING OF NAMES 
###

# a mix of regexes and strings defining words that should be always up/down-cased
@uppercasers = [/^\w?CC\w?$/i, /^\w?TC$/i, /^[NS]?[EW]?$/i, /^SR-?\d/i, /^[AP]M$/i, 
				'HS', 'P&R', 'C.B.D.', 'DART', 'LINK' ]
@downcasers = ['AND', 'VIA', 'TO']

# properly cases all the words in a string.
def proper_case(string)
	# split on spaces for big words to join with spaces
	# then split on other delimiters to get actual words for proper casing
	string.split(' ').map {|word| word.split(/(\/|\.|-)/).map do |w| 
		if includes?(@uppercasers, w) then w.upcase
		elsif includes?(@downcasers, w) then w.downcase
		else w.capitalize end
	end.join() }.join(' ')
end

# returns whether array of regular expressions and strings contains word
def includes?(array, word)
	array.each do |rule|
		# if regexp then match else uppercase string compare 
		return true if (rule.class() == Regexp and rule =~ word) or
					   (rule == word.upcase)
	end
	return false
end

###
# AND NOW, THE SEED SCRIPT SPECTACULAR:
###

@agency_codes = { '1' => 'KCM', 'KMD' => 'KMD', '40' => 'ST'} #'EOS'

# create each agency
#   create each route in agency
#     create each stop on route
#     create links btw stops and route
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
	puts "+agency - #{agency.oba_id}: #{agency.name}"
	route_count = 0

	oba_api("routes-for-agency", agency.oba_id)['list'].each do |rte|
		# create the route record through the agency to build the relationship
		route = Route.find_or_create_by_oba_id(rte['id'],{
								agency_code: agency.code,
								code: /_([\w\d]+)/.match(rte['id'])[1],
								name: rte['shortName'].empty? ? proper_case(rte['longName']) : rte['shortName'],
								description: proper_case(rte['description']),
								route_type: rte['type'],
								url: rte['url']
							})
		route.agency = agency
		puts "  +route - #{route.oba_id}: #{route.name} (#{route.code})"

		# load the stops for this route. 
		# but this API contains a lot of data so we'll save it and reference individual parts
		route_data = oba_api("stops-for-route", route.oba_id)

		# the polylines for the route are in one part of the route_data
		route.polylines = route_data['polylines'].map {|line| line['points'] }.join(',')
		route.save!
		route_count += 1

		print "    +stops "
		# and all the stops are in another!
		route_data['stops'].each_with_index do |s, count|
			stop = Stop.find_or_create_by_oba_id(s['id'], {
											agency_code: agency.code,
											code: s['code'],
											name: proper_case(s['name']),
											direction: s['direction'].upcase,
											stop_type: s['locationType'],
											lon: s['lon'],
											lat: s['lat']
									})
			stop.agency = agency
			stop.save!
			print '.' if count % 5 == 0
			# puts "    +stop - #{stop.oba_id}: #{stop.name} (#{stop.code})"
		end
		puts " #{route_data['stops'].length}"

		# hold up, the stop groupings are deeply buried in another part
		route_data['stopGroupings'][0]['stopGroups'].each do |group|
			group['stopIds'].each_with_index do |id, index|
				link = RouteStop.new({
					index: index,
					group: group['id'].to_i,
				})
				link.route = route
				link.stop = Stop.find_by_oba_id(id)
				link.save!
			end
			name = group['name']['name']
			puts "    +group #{proper_case name} (#{group['id']}): #{group['stopIds'].length} stops"
		end
	end
	puts "  =new routes: #{route_count}"
end

@totalTime = (Time.now - @startTime).to_i

puts ""
puts "======================"
puts "|| The Grand Totals:"
puts "||  #{Agency.all.count} agencies"
puts "||  #{Route.all.count} routes"
puts "||  #{Stop.all.count} stops"
puts "||  #{@request_count} requests"
puts "||  #{@totalTime / 60}:#{@totalTime % 60} elapsed"
puts "======================"

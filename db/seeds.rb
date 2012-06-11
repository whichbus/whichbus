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

@request_count = 0
def get_json(url)
	@request_count += 1
	puts "(get #{@request_count}: #{url})"
	JSON.parse(open(url, 'Content-Type' => 'application/json').read)
end

def oba_api(method, params=nil)
	@query = ""
	params.each {|key, value| @query += "&#{key}=#{value}"} unless params.nil?

	return get_json("http://api.onebusaway.org/api/where/#{method}.json?key=TEST#{@query}")['data']
end

def proper_case(string)
	string.split(' ').map {|w| @uppercasers.include?(w) ? w.upcase : w.capitalize }.join(' ')
end

oba_api("agencies-with-coverage").each do |a|
	data = a['agency']
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

	oba_api("routes-for-agency/#{data['id']}")['list'].first(5).each do |rte|
		route = agency.routes.create({
						oba_id: rte['id'],
						agency_code: agency.code,
						code: /_([\w\d]+)/.match(rte['id'])[1],
						name: rte['shortName'].empty? ? proper_case(rte['longName']) : rte['shortName'],
						description: proper_case(rte['description']),
						route_type: rte['type'],
						url: rte['url']
					})
		puts "  +route - #{route.oba_id}: #{route.name} (#{route.code})"

		#oba_api("stops-for-route/#{route.id}")['stops'].each do |s|
	end
end
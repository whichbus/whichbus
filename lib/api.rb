require 'open-uri'
require 'cgi'

module API
	@data_count = 0

	def get_json(url, verbose=true)
		@data_count += 1
		puts "JSON REQUEST #{@data_count}: #{url}" if verbose

		JSON.parse(open(url, 'Content-Type' => 'application/json').read)
	end

	def open_trip_planner(method, params)
		method = "transit/#{method}" unless method == 'plan' or method == 'metadata'
		get_json("http://api.whichbus.org/otp/#{method}?#{query_string params}")
	end

	# quick and easy way to query the OneBusAway API
	def one_bus_away(method, id=nil, params={})
		# optional id parameter. omit it and it will be ignored
		if id.is_a? Hash 
			params = id
			id = nil
		end
		
		# encode ID in URL if it exists
		method += "/" + ERB::Util.url_encode(id) unless id.nil?

		result = get_json("http://api.onebusaway.org/api/where/#{method}.json?key=TEST&#{query_string params}")['data']
		(result.is_a?(Hash) and result.has_key?('entry')) ? result['entry'] : result
	end

	def self.query_string(params)
		[:format, :controller, :action, :method].each {|key| params.delete key }
		params.map {|key, value| "#{key}=#{CGI::escape value}"}.join('&')
	end

	module_function :get_json
	module_function :open_trip_planner
	module_function :one_bus_away
end

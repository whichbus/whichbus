require 'open-uri'

module API
	@data_count = 0

	def get_json(url, verbose=true)
		@data_count += 1
		puts "JSON REQUEST #{@data_count}: #{url}" if verbose

		JSON.parse(open(url, 'Content-Type' => 'application/json').read)
	end

	def open_trip_planner(method, params)
		url = "http://otp.whichb.us:8080/opentripplanner-api-webapp/ws/transit/#{method}"
		if params.has_key?("agency")
			url += "?agency=#{params[:agency]}&id=#{params[:id]}"
		elsif params.has_key?("lat")
			url += "?lat=#{params[:lat]}&lon=#{params[:lon]}"
		end
		get_json(url)
	end

	# quick and easy way to query the OneBusAway API
	def one_bus_away(method, id=nil, params={})
		# optional id parameter. omit it and it will be ignored
		if id.is_a? Hash 
			params = id
			id = nil
		end

		# prepare the query parameter string
		# params['includeReferences'] = false
		[:format, :controller, :action, :method, :id].each {|key| params.delete key }
		@query = params.map {|key, value| "#{key}=#{value}"}.join('&')
		
		# encode ID in URL if it exists
		method += "/" + ERB::Util.url_encode(id) unless id.nil?

		puts "method: #{method}, query: #{@query}"
		result = get_json("http://api.onebusaway.org/api/where/#{method}.json?key=TEST&#{@query}")['data']
		(result.is_a?(Hash) and result.has_key?('entry')) ? result['entry'] : result
	end

	module_function :get_json
	module_function :open_trip_planner
	module_function :one_bus_away
end
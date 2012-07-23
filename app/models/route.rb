class Route < ActiveRecord::Base
	attr_accessible :oba_id, :agency_code, :code, :name, :description, :url, :color, :polylines, :route_type

	belongs_to :agency

	has_many :route_stops
	has_many :stops, :through => :route_stops, :order => ['"route_stops"."group"', '"route_stops"."index"']

	def kcm_id
		"#{@agency_code or '?'}/#{code}"
	end

	def trips
		response = API.one_bus_away('trips-for-route', oba_id, includeStatus: 'true')
		response['list'].map do |trip|
			refTrip = response['references']['trips'].find { |t| t['id'] == trip['tripId'] }
			trip['status']['headsign'] = refTrip['tripHeadsign']
			trip['status']['nextStopName'] = Stop.find_by_oba_id(trip['status']['nextStop']).name
			%w(lastLocationUpdateTime lastKnownLocation lastKnownOrientation lastUpdateTime lastKnownDistanceAlongTrip).each do |k|
				trip['status'].delete k
			end
			trip['status']
		end
	end
end

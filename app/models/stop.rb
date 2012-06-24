class Stop < ActiveRecord::Base
	attr_accessible :oba_id, :agency_code, :code, :name, :lat, :lon, :direction, :stop_type

	belongs_to :agency

	has_many :route_stops
	has_many :routes, :through => :route_stops

	def kcm_id
		"#{agency_code}/#{code}"
	end

	def schedules
		@schedules ||= API.one_bus_away('schedule-for-stop', oba_id)['stopRouteSchedules']
		@schedules
	end

	def arrivals
		API.one_bus_away('arrivals-and-departures-for-stop', oba_id)['arrivalsAndDepartures']
	end
end

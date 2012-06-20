class Stop < ActiveRecord::Base
	attr_accessible :oba_id, :agency_code, :code, :name, :lat, :lon, :direction, :stop_type

	belongs_to :agency

	has_many :route_stops
	has_many :routes, :through => :route_stops

	def kcm_id
		"#{@agency_code}/#{code}"
	end
end

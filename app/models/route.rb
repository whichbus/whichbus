class Route < ActiveRecord::Base
	attr_accessible :oba_id, :agency_code, :code, :name, :description, :url, :color, :polylines, :route_type

	belongs_to :agency

	has_many :route_stops
	has_many :stops, :through => :route_stops, :order => ['"route_stops"."group"', '"route_stops"."index"']

	def kcm_id
		"#{@agency_code or '?'}/#{code}"
	end
end

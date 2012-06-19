class Route < ActiveRecord::Base
  attr_accessible :oba_id, :agency_code, :code, :color, :description, :name, :polylines, :route_type, :url

  belongs_to :agency

  has_many :route_stops
  has_many :stops, :through => :route_stops, :order => ['"route_stops"."group"', '"route_stops"."index"']

  def kcm_id
  	"#{@agency_code or '?'}/#{code}"
  end
end

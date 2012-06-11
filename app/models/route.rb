class Route < ActiveRecord::Base
  attr_accessible :oba_id, :agency_code, :code, :color, :description, :name, :polylines, :route_type, :url

  belongs_to :agency
  has_and_belongs_to_many :stops
end

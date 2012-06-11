class Stop < ActiveRecord::Base
  attr_accessible :oba_id, :agency_code, :code, :direction, :lat, :lon, :name, :stop_type

  belongs_to :agency
  has_and_belongs_to_many :routes
end

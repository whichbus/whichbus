class Agency < ActiveRecord::Base
  attr_accessible :oba_id, :code, :disclaimer, :name, :phone, :timezone, :url

  has_many :routes
end

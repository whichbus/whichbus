class Agency < ActiveRecord::Base
  attr_accessible :oba_id, :code, :name, :url, :phone, :timezone, :disclaimer

  has_many :routes
end

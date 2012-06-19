# a join model linking Route and Stop with a group and index for ordering
class RouteStop < ActiveRecord::Base
  attr_accessible :group, :index

  belongs_to :route
  belongs_to :stop
end

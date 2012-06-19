class CreateRouteStops < ActiveRecord::Migration
  def change
    create_table :route_stops do |t|
      t.references :route
      t.references :stop
      t.integer :index
      t.integer :group
    end
  end
end

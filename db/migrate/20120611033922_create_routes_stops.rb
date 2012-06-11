class CreateRoutesStops < ActiveRecord::Migration
  def change
    create_table :routes_stops do |t|
      t.references :route
      t.references :stop
      t.integer :index
    end
  end
end

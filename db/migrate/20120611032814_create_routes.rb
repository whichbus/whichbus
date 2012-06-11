class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :code
      t.string :agency_code
      t.string :name
      t.string :description
      t.string :route_type
      t.string :url
      t.string :color
      t.text :polylines
      t.references :agency

      t.timestamps
    end
  end
end

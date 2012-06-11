class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.string :code
      t.string :agency_code
      t.string :name
      t.string :direction
      t.float :lat
      t.float :lon
      t.string :stop_type
      t.references :agency

      t.timestamps
    end
  end
end

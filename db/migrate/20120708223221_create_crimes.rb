class CreateCrimes < ActiveRecord::Migration
  def change
    create_table :crimes do |t|
      t.timestamp :time
      t.float :latitude
      t.float :longitude
      t.integer :summary_code
      t.string :address
      t.timestamps
    end
  end
end

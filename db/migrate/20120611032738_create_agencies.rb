class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :code
      t.string :name
      t.string :url
      t.string :timezone
      t.string :phone
      t.string :disclaimer

      t.timestamps
    end
  end
end

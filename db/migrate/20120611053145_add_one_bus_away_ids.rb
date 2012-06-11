class AddOneBusAwayIds < ActiveRecord::Migration
  def change
  	add_column :agencies, :oba_id, :string
  	add_column :routes, :oba_id, :string
  	add_column :stops, :oba_id, :string
  end
end

class Stop < ActiveRecord::Migration
  def self.up
    add_column :stops, :safety, :integer
  end

  def self.down
    remove_column :stops, :safety
  end
end

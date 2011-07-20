class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.string :name
      t.string :organization
      t.string :email
      t.string :phone
      t.string :currency
      t.string :cached_slug
      t.integer :events
      t.integer :stations
      t.decimal :maintenance_budget, :precision => 15, :scale => 2
      t.integer :treatment_vehicles
      t.decimal :treatment_miles, :precision => 10, :scale => 2
      t.integer :routes
      t.decimal :cleanup_miles, :precision => 10, :scale => 2
      t.decimal :dry_material_use, :precision => 10, :scale => 2
      t.decimal :wet_material_use, :precision => 10, :scale => 2
      t.integer :population
      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end

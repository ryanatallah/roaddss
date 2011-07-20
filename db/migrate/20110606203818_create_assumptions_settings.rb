class CreateAssumptionsSettings < ActiveRecord::Migration
  def self.up
    create_table :assumptions_settings do |t|
      t.integer :record_id
      t.integer :treatments_per_year
      t.decimal :decision_maker_rate, :precision => 10, :scale => 2
      t.decimal :driver_rate, :precision => 10, :scale => 2
      t.decimal :complaint_labor_cost, :precision => 10, :scale => 2
      t.integer :regions
      t.decimal :decision_hrs, :precision => 10, :scale => 2
      t.integer :drivers
      t.integer :decision_makers
      t.decimal :stress_absences, :precision => 10, :scale => 2
      t.decimal :it_labor_costs, :precision => 10, :scale => 2
      t.decimal :it_hardware_costs, :precision => 10, :scale => 2
      t.decimal :vehicle_mpg, :precision => 10, :scale => 2
      t.decimal :fuel_cost, :precision => 10, :scale => 2
      t.decimal :fleet_cleaning, :precision => 10, :scale => 2
      t.decimal :fleet_servicing, :precision => 10, :scale => 2
      t.decimal :equipment_replacement_costs, :precision => 10, :scale => 2
      t.decimal :dry_material_cost, :precision => 10, :scale => 2
      t.decimal :wet_material_cost, :precision => 10, :scale => 2
      t.decimal :cleanup_time_per_mile, :precision => 10, :scale => 2
      t.decimal :treatment_hrs_per_event_driver, :precision => 10, :scale => 2
      t.decimal :cleanup_miles_per_route, :precision => 10, :scale => 2
      t.decimal :cleanup_hrs_per_route, :precision => 10, :scale => 2
      t.decimal :cost_per_major_accident, :precision => 10, :scale => 2
      t.decimal :cost_per_fatality, :precision => 10, :scale => 2
      t.decimal :total_local_economy, :precision => 15, :scale => 2
      t.decimal :community_fuel_economy, :precision => 10, :scale => 2
      t.decimal :miles_per_vehicle, :precision => 10, :scale => 2
      t.decimal :litigation_cost_accident, :precision => 10, :scale => 2
      t.decimal :litigation_cost_fatality, :precision => 10, :scale => 2
      t.decimal :accidents_per_event, :precision => 10, :scale => 2
      t.decimal :fatalities, :precision => 10, :scale => 2
      t.decimal :complaints, :precision => 10, :scale => 2
      t.decimal :economy_affected_pct, :precision => 10, :scale => 2
      t.decimal :traffic_speed, :precision => 10, :scale => 2
      t.decimal :vehicles_on_road, :precision => 10, :scale => 2
      t.decimal :infrastructure_wear_costs, :precision => 10, :scale => 2
      t.decimal :vegetation_replacement_costs, :precision => 10, :scale => 2
      t.decimal :co2_diesel, :precision => 10, :scale => 2
      t.decimal :co2_gas, :precision => 10, :scale => 2
      t.decimal :tolls_per_vehicle, :precision => 10, :scale => 2
      t.decimal :toll_roads_vehicles, :precision => 10, :scale => 2
      t.decimal :emergency_vehicles_event, :precision => 10, :scale => 2

      t.timestamps
    end
    add_index :assumptions_settings, :record_id
  end

  def self.down
    drop_table :assumptions_settings
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110822044344) do

  create_table "assumptions_settings", :force => true do |t|
    t.integer  "record_id"
    t.integer  "treatments_per_year"
    t.decimal  "decision_maker_rate"
    t.decimal  "driver_rate"
    t.decimal  "complaint_labor_cost"
    t.integer  "regions"
    t.decimal  "decision_hrs"
    t.integer  "drivers"
    t.integer  "decision_makers"
    t.decimal  "stress_absences"
    t.decimal  "it_labor_costs"
    t.decimal  "it_hardware_costs"
    t.decimal  "vehicle_mpg"
    t.decimal  "fuel_cost"
    t.decimal  "fleet_cleaning"
    t.decimal  "fleet_servicing"
    t.decimal  "equipment_replacement_costs"
    t.decimal  "dry_material_cost"
    t.decimal  "wet_material_cost"
    t.decimal  "cleanup_time_per_mile"
    t.decimal  "treatment_hrs_per_event_driver"
    t.decimal  "cleanup_miles_per_route"
    t.decimal  "cleanup_hrs_per_route"
    t.decimal  "cost_per_major_accident"
    t.decimal  "cost_per_fatality"
    t.decimal  "total_local_economy"
    t.decimal  "community_fuel_economy"
    t.decimal  "miles_per_vehicle"
    t.decimal  "litigation_cost_accident"
    t.decimal  "litigation_cost_fatality"
    t.decimal  "accidents_per_event"
    t.decimal  "fatalities"
    t.decimal  "complaints"
    t.decimal  "economy_affected_pct"
    t.decimal  "traffic_speed"
    t.decimal  "vehicles_on_road"
    t.decimal  "infrastructure_wear_costs"
    t.decimal  "vegetation_replacement_costs"
    t.decimal  "co2_diesel"
    t.decimal  "co2_gas"
    t.decimal  "tolls_per_vehicle"
    t.decimal  "toll_roads_vehicles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "emergency_vehicles_event"
  end

  add_index "assumptions_settings", ["record_id"], :name => "index_assumptions_settings_on_record_id"

  create_table "records", :force => true do |t|
    t.string   "name"
    t.string   "organization"
    t.string   "email"
    t.string   "phone"
    t.string   "currency"
    t.integer  "events"
    t.integer  "stations"
    t.decimal  "maintenance_budget"
    t.integer  "treatment_vehicles"
    t.decimal  "treatment_miles"
    t.integer  "routes"
    t.decimal  "cleanup_miles"
    t.decimal  "dry_material_use"
    t.decimal  "wet_material_use"
    t.integer  "population"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.boolean  "contactable"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

end

class Record < ActiveRecord::Base
  has_one :assumptions_setting, :dependent => :destroy
  accepts_nested_attributes_for :assumptions_setting

  validates_presence_of :name,
                        :organization,
                        :email,
                        :phone,
                        :currency,
                        :events,
                        :stations,
                        :maintenance_budget,
                        :treatment_vehicles,
                        :treatment_miles,
                        :routes,
                        :cleanup_miles,
                        :dry_material_use,
                        :wet_material_use,
                        :population,
                        :cached_slug

  has_friendly_id :code, :use_slug => true

  def code
    ActiveSupport::SecureRandom.hex(6)
  end

  def ccy_symb
    self.currency == "USD" || self.currency == "CAD" ? "$" :
    self.currency == "GBP" ? "&pound;" :
    self.currency == "EUR" ? "&euro;" : nil
  end

  CURRENCY_CONVERSION = {
    "USD" => 1,
    "GBP" => 0.616181,
    "EUR" => 0.70618,
    "CAD" => 0.97415
  }

  LOOKUP_USD = {
    "gdp"        => 47400,
    "population" => 313232044,
    "economy"    => 1470000000000,
    "vehicles"   => 257494000,
    "fatalities" => 30797,
    "accidents"  => 1548000
  }

  LOOKUP_GBP = {
    "gdp"        => 35100,
    "population" => 62698362,
    "economy"    => 219000000000,
    "vehicles"   => 33717000,
    "fatalities" => 3505,
    "accidents"  => 169805
  }

  LOOKUP_EUR = {
    "gdp"        => 32900,
    "population" => 492387344,
    "economy"    => 1490000000000,
    "vehicles"   => 269158000,
    "fatalities" => 43576,
    "accidents"  => 1219000
  }

  LOOKUP_CAD = {
    "gdp"        => 39600,
    "population" => 34030589,
    "economy"    => 134000000000,
    "vehicles"   => 7920000,
    "fatalities" => 2900,
    "accidents"  => 160000
  }

  def ccy(num)
    CURRENCY_CONVERSION[self.currency] * num
  end

  def lookup(var)
    if self.currency == "USD"
      LOOKUP_USD[var]
    elsif self.currency == "GBP"
      LOOKUP_GBP[var]
    elsif self.currency == "EUR"
      LOOKUP_EUR[var]
    elsif self.currency == "CAD"
      LOOKUP_CAD[var]
    end
  end

  BENEFIT = {
    "treatments_per_year"            => 0.70, # Number of Weather Events
    "decision_hrs"                   => 0.33, # Customer Labor & Infrastructure
    "drivers"                        => 0.80,
    "decision_makers"                => 0.83,
    "stress_absences"                => 0.25,
    "it_labor_costs"                 => 0.80,
    "it_hardware_costs"              => 0.25,
    "treatment_vehicles"             => 0.80, # Maintenance Fleet Vehicles
    "equipment_replacement_costs"    => 0.80,
    "treatment_hrs_per_event_driver" => 0.80, # Treatment
    "treatment_miles"                => 0.80,
    "dry_material_use"               => 0.50,
    "wet_material_use"               => 0.50,
    "cleanup_miles_per_route"        => 0.80,
    "cleanup_miles"                  => 0.80,
    "cleanup_hrs_per_route"          => 0.80,
    "cleanup_hrs"                    => 0.80,
    "accidents_per_event"            => 0.80, # Community & Infrastructure
    "fatalities"                     => 0.60,
    "complaints"                     => 0.50,
    "economy_affected_pct"           => 0.50,
    "traffic_speed"                  => 2.30,
    "vehicles_on_road"               => 1.10,
    "infrastructure_wear_costs"      => 0.75,
    "vegetation_replacement_costs"   => 0.60,
    "toll_roads_vehicles"            => 1.30, # Other
    "environmental_cost"             => 0.50
  }

  def pro(attrib)
    a = ["treatment_vehicles",
         "treatment_miles",
         "cleanup_miles",
         "dry_material_use",
         "wet_material_use", # these attributes are in the Record model, not AssumptionsSetting
         "environmental_cost"] # environmental_cost is an output method, used as a function with a pro factor

    b = ["treatments_per_year",
         "decision_makers",
         "treatment_vehicles"] # these attributes should be integers

    if a.include? attrib
      @setting = self
    else
      @setting = self.assumptions_setting
    end

    if b.include? attrib
      ( @setting.send(attrib) * BENEFIT[attrib.to_s] ).to_i
    else
      @setting.send(attrib) * BENEFIT[attrib.to_s]
    end
  end

  # Calculator Output Methods

  ## EFFICIENCY
  ### SAVINGS BENEFITS
  def decision_time_savings
    self.decision_time_reduction * self.assumptions_setting.decision_maker_rate
  end

  def treatment_labor_usage_savings
    self.driving_time_reduction * self.assumptions_setting.driver_rate
  end

  def reduced_stress_absences_savings
    self.stress_absences_reduction * self.assumptions_setting.decision_maker_rate
  end

  def dry_material_savings
    self.dry_material_reduction * self.assumptions_setting.dry_material_cost
  end

  def wet_material_savings
    self.wet_material_reduction * self.assumptions_setting.wet_material_cost
  end

  def cleanup_labor_savings
    self.cleanup_labor_time_reduction * self.assumptions_setting.driver_rate
  end

  def vehicle_maintenance_savings
    ( # Original treatment + original cleaning costs
      self.treatment_vehicles * ( self.assumptions_setting.treatments_per_year * self.assumptions_setting.fleet_cleaning + self.assumptions_setting.fleet_servicing ) + 
      self.assumptions_setting.equipment_replacement_costs
    ) - 
    ( # Proactive treatment + proactive cleaning costs
      self.pro("treatment_vehicles") * ( self.pro("treatments_per_year") * self.assumptions_setting.fleet_cleaning + self.assumptions_setting.fleet_servicing ) + 
      self.pro("equipment_replacement_costs")
    )
  end

  def fuel_consumption_savings
    if self.currency == "EUR" || self.currency == "CAD"
      fuel_consumption_cost = self.assumptions_setting.fuel_cost * self.assumptions_setting.vehicle_mpg / 100 # Metric fuel consumption is expressed in Liters per 100 km
    else
      fuel_consumption_cost = self.assumptions_setting.fuel_cost / self.assumptions_setting.vehicle_mpg
    end
    
    (
      ( # Treatment fuel savings
        self.treatment_miles * self.assumptions_setting.treatments_per_year - 
        self.pro("treatment_miles") * self.pro("treatments_per_year")
      ) + 
      ( # Cleanup fuel savings
        self.cleanup_miles * self.assumptions_setting.treatments_per_year - 
        self.pro("cleanup_miles") * self.pro("treatments_per_year")
      )
    ) * fuel_consumption_cost
  end

  def wear_infrastructure_savings
    ( self.assumptions_setting.infrastructure_wear_costs + self.assumptions_setting.vegetation_replacement_costs ) -
    ( self.pro("infrastructure_wear_costs") + self.pro("vegetation_replacement_costs") )
  end

  def it_hardware_savings
    self.assumptions_setting.it_hardware_costs - self.pro("it_hardware_costs")
  end

  def it_labor_savings
    self.assumptions_setting.it_labor_costs - self.pro("it_labor_costs")
  end

  def toll_revenue_increase
    ( # Increase in vehicles on toll roads
      self.pro("toll_roads_vehicles") - self.assumptions_setting.toll_roads_vehicles
    ) * self.events * self.assumptions_setting.tolls_per_vehicle
  end

  def total_efficiency_savings
    self.decision_time_savings           +
    self.treatment_labor_usage_savings   +
    self.reduced_stress_absences_savings +
    self.dry_material_savings            +
    self.wet_material_savings            +
    self.cleanup_labor_savings           +
    self.vehicle_maintenance_savings     +
    self.fuel_consumption_savings        +
    self.wear_infrastructure_savings     +
    self.it_hardware_savings             +
    self.it_labor_savings                +
    self.toll_revenue_increase
  end

  #### SUMMARY ITEMS
  def labor_time_savings
    self.decision_time_savings           +
    self.treatment_labor_usage_savings   +
    self.reduced_stress_absences_savings +
    self.cleanup_labor_savings           +
    self.it_labor_savings
  end

  def material_savings
    self.dry_material_savings            +
    self.wet_material_savings            +
    self.fuel_consumption_savings        +
    self.it_hardware_savings
  end

  def maintenance_wear_savings
    self.vehicle_maintenance_savings     +
    self.wear_infrastructure_savings
  end

  def increased_revenue
    self.toll_revenue_increase
  end

  def percent_budget_saved
    self.total_efficiency_savings / self.maintenance_budget
  end

  def savings_per_region
    self.total_efficiency_savings / self.assumptions_setting.regions
  end

  def increased_value_per_station
    self.total_efficiency_savings / self.stations
  end

  ## EFFICIENCY
  ### REDUCTION BENEFITS
  def decision_time_reduction
    self.assumptions_setting.decision_hrs * self.assumptions_setting.treatments_per_year - 
    self.pro("decision_hrs") * self.pro("treatments_per_year")
  end

  def driving_time_reduction
    self.assumptions_setting.treatment_hrs_per_event_driver * self.assumptions_setting.drivers * self.assumptions_setting.treatments_per_year - 
    self.pro("treatment_hrs_per_event_driver") * self.pro("drivers") * self.pro("treatments_per_year")
  end

  def stress_absences_reduction
    (
      self.assumptions_setting.decision_makers * self.assumptions_setting.stress_absences - 
      self.pro("decision_makers") * self.pro("stress_absences")
    ) * 8
  end

  def dry_material_reduction
    self.dry_material_use * self.assumptions_setting.treatments_per_year - 
    self.pro("dry_material_use") * self.pro("treatments_per_year")
  end

  def wet_material_reduction
    self.wet_material_use * self.assumptions_setting.treatments_per_year - 
    self.pro("wet_material_use") * self.pro("treatments_per_year")
  end

  def cleanup_labor_time_reduction
    (
      self.cleanup_miles * self.assumptions_setting.treatments_per_year - 
      self.pro("cleanup_miles") * self.pro("treatments_per_year")
    ) * self.assumptions_setting.cleanup_time_per_mile
  end

  def required_vehicles_reduction
    self.treatment_vehicles - self.pro("treatment_vehicles")
  end

  def operation_people_reduction
    ( self.assumptions_setting.drivers + self.assumptions_setting.decision_makers ) - 
    ( self.pro("drivers") + self.pro("decision_makers") )
  end

  def driven_lane_miles_reduction
    ( self.treatment_miles + self.cleanup_miles ) * self.assumptions_setting.treatments_per_year - 
    ( self.pro("treatment_miles") + self.pro("cleanup_miles") ) * self.pro("treatments_per_year")
  end

  def it_labor_reduction
    it_rate = self.assumptions_setting.driver_rate
    ( self.assumptions_setting.it_labor_costs - self.pro("it_labor_costs") ) / it_rate
  end

  def toll_vehicles_increase
    self.events * ( self.pro("toll_roads_vehicles") - self.assumptions_setting.toll_roads_vehicles )
  end


  ## PUBLICITY
  ### SAVINGS BENEFITS
  def complaint_savings
    self.complaints_reduction * self.assumptions_setting.complaint_labor_cost
  end

  def litigation_savings
    ( self.accidents_reduction * self.assumptions_setting.litigation_cost_accident + 
      self.fatalities_reduction * self.assumptions_setting.litigation_cost_fatality ) * 0.05
  end

  def total_publicity_savings
    self.complaint_savings + self.litigation_savings
  end

  ## PUBLICITY
  ### REDUCTION BENEFITS
  def complaints_reduction
    self.assumptions_setting.complaints - self.pro("complaints")
  end

  def lawsuits_reduction
    0.05 * ( self.accidents_reduction + self.fatalities_reduction )
  end


  ## SAFETY
  ### SAVINGS BENEFITS
  def accident_savings
    self.accidents_reduction * self.assumptions_setting.cost_per_major_accident
  end

  def fatality_savings
    self.fatalities_reduction * self.assumptions_setting.cost_per_fatality
  end

  def total_safety_savings
    self.accident_savings + self.fatality_savings
  end

  ## SAFETY
  ### REDUCTION BENEFITS
  def accidents_reduction
    ( self.assumptions_setting.accidents_per_event - self.pro("accidents_per_event") ) * self.events
  end

  def fatalities_reduction
    self.assumptions_setting.fatalities - self.pro("fatalities")
  end

  def emergency_response_time_reduction
    self.assumptions_setting.emergency_vehicles_event * self.assumptions_setting.miles_per_vehicle *
    ( self.assumptions_setting.treatments_per_year / self.assumptions_setting.traffic_speed - 
      self.pro("treatments_per_year") / self.pro("traffic_speed") )
  end


  ## MOBILITY
  ### SAVINGS BENEFITS
  def traffic_flow
    
  end

  def local_economy_losses_reduction
    self.assumptions_setting.total_local_economy * 0.35 / 150.to_f * self.events * 
    ( # Reduction percentage
      ( 1 - self.pro("economy_affected_pct") ) - ( 1 - self.assumptions_setting.economy_affected_pct )
    )
  end

  def total_community_savings
    self.local_economy_losses_reduction
  end

  ## MOBILITY
  ### REDUCTION BENEFITS
  def average_speed_increase
    self.pro("traffic_speed") - self.assumptions_setting.traffic_speed
  end

  def road_vehicles_increase
    self.pro("vehicles_on_road") - self.assumptions_setting.vehicles_on_road
  end

  def community_time_savings
    (
      self.assumptions_setting.vehicles_on_road / self.assumptions_setting.traffic_speed - 
      self.pro("vehicles_on_road") / self.pro("traffic_speed")
    ) * self.events * self.assumptions_setting.miles_per_vehicle
  end

  ## ENVIRONMENT
  ### SAVINGS BENEFITS
  def pollution_savings
    (
      ( # Savings from CO2 reduction
        self.assumptions_setting.vehicles_on_road * 5000.0 - 
        self.pro("vehicles_on_road") * 3500.0
      ) + 
      ( # Savings from nitros oxide reduction
        self.assumptions_setting.vehicles_on_road * 50000.0 - 
        self.pro("vehicles_on_road") * 40000.0
      )
    ) * self.ccy(0.0119 * 1.609 / 25100.0) * self.events * self.assumptions_setting.miles_per_vehicle
  end

  def co2_community_cost_avoidance
    co2_avoidance_cost = 600 # USD/Ton CO2
    self.ghg_reduction * self.ccy(co2_avoidance_cost)
  end

  def veh_infrastructure_savings
    salt_cost = 30.17 # Vehicle infrastructure salt cost per vehicle

    self.ccy(self.population * salt_cost) * self.lookup("vehicles") / self.lookup("population") * ( 1.00 - 0.50 ) # Multiplier replaces proactive factor of 0.50
  end
  def veh_infrastructure_savings_pre
    salt_cost = 30.17 # Vehicle infrastructure salt cost per vehicle

    self.ccy(self.population * salt_cost) * self.lookup("vehicles") / self.lookup("population") # Multiplier replaces proactive factor of 0.50
  end

  def environmental_savings
    salt_cost_per_mile = 5072.68
    self.ccy(self.treatment_miles * salt_cost_per_mile) * ( 1.00 - 0.50 ) # Multiplier replaces proactive factor of 0.50
  end

  def total_environment_savings
    self.pollution_savings + self.co2_community_cost_avoidance + self.veh_infrastructure_savings + self.environmental_savings
  end

  ## ENVIRONMENT
  ### REDUCTION BENEFITS
  def road_treatment_materials_reduction
    self.dry_material_use * self.assumptions_setting.treatments_per_year - 
    self.pro("dry_material_use") * self.pro("treatments_per_year")
  end

  def ghg_reduction
    miles_driven = self.assumptions_setting.vehicles_on_road * self.assumptions_setting.miles_per_vehicle
    pro_miles_driven = self.pro("vehicles_on_road") * self.assumptions_setting.miles_per_vehicle

    ( miles_driven - pro_miles_driven * ( 1.00 - 0.34444444 ) ) * 
    self.assumptions_setting.co2_gas * self.events * 
    if self.currency == "USD" || self.currency == "GBP"
      1.00 / 2000.0 / self.assumptions_setting.community_fuel_economy
    else
      self.assumptions_setting.community_fuel_economy / 100.00 / 1000.00
    end
  end

  def polluting_emissions_reduction
    if self.currency == "USD" || self.currency == "GBP"
      mass = 1.00
    else
      mass = 0.45359237
    end
    self.treatment_miles * mass * ( 8.0 + 2.1 + 9.5 ) / 453.5924 * (
      ( # NOX voc co emissions
        self.assumptions_setting.treatments_per_year
      ) - 
      ( # Proactive NOX voc co emissions
        self.pro("treatments_per_year") * ( 1 - 0.33184855233853 ) # Percent Change NOx Use
      )
    )
  end
end

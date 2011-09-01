class AssumptionsSetting < ActiveRecord::Base
  belongs_to :record
  before_create :default_values

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
    CURRENCY_CONVERSION[self.record.currency] * num
  end

  def lookup(var)
    if self.record.currency == "USD"
      LOOKUP_USD[var]
    elsif self.record.currency == "GBP"
      LOOKUP_GBP[var]
    elsif self.record.currency == "EUR"
      LOOKUP_EUR[var]
    elsif self.record.currency == "CAD"
      LOOKUP_CAD[var]
    end
  end

  def default_values
    self.treatments_per_year            = self.record.events
    self.decision_maker_rate            = self.ccy(80)
    self.driver_rate                    = self.ccy(60)
    self.complaint_labor_cost           = self.ccy(10)
    self.regions                        = 5
    self.decision_hrs                   = 3
    self.drivers                        = (self.record.treatment_vehicles * 1.36).ceil
    self.decision_makers                = (self.record.routes.to_f / 50).ceil * 2 + 2
    self.stress_absences                = self.decision_makers
    self.it_labor_costs                 = self.ccy(80000)
    self.it_hardware_costs              = self.ccy(4000)
    self.vehicle_mpg                    = self.record.currency == "USD" ? 4 : self.record.currency == "GBP" ? 5 : 58.8
    self.fuel_cost                      = self.ccy(self.record.currency == "USD" ? 3.50 : self.record.currency == "GBP" ? 11.1 : 1.55 / 0.7)
    self.fleet_cleaning                 = self.ccy(100)
    self.fleet_servicing                = self.ccy(8000)
    self.equipment_replacement_costs    = self.ccy(self.record.maintenance_budget * 0.24)
    self.dry_material_cost              = self.ccy(self.record.currency == "USD" ? 69.00 : self.record.currency == "GBP" ? 69.00 / 0.8929 : 69.00 / 0.9072)
    self.wet_material_cost              = self.ccy(self.record.currency == "USD" ? 0.63 : self.record.currency == "GBP" ? 0.63 / 0.8327 : 0.63 / 3.7854)
    self.cleanup_time_per_mile          = self.record.currency == "USD" || self.record.currency == "GBP" ? 10 / 60.to_f : 10 / 60.to_f / 1.6
    self.treatment_hrs_per_event_driver = 5
    self.cleanup_miles_per_route        = self.record.cleanup_miles / self.record.routes
    self.cleanup_hrs_per_route          = self.cleanup_time_per_mile * self.cleanup_miles_per_route
    self.cost_per_major_accident        = self.ccy(250000)
    self.cost_per_fatality              = self.ccy(4200000)
    self.total_local_economy            = self.record.population * self.ccy(self.lookup("gdp"))
    self.community_fuel_economy         = self.record.currency == "USD" ? 20 : self.record.currency == "GBP" ? 24 : 12
    self.miles_per_vehicle              = self.record.currency == "USD" || self.record.currency == "GBP" ? 20 : 38
    self.litigation_cost_accident       = self.ccy(15000)
    self.litigation_cost_fatality       = self.ccy(1100000)
    self.accidents_per_event            = self.lookup("accidents") / self.lookup("population").to_f * self.record.population / 365.ceil
    self.fatalities                     = self.lookup("fatalities") / self.lookup("population").to_f * self.record.population * 5 / 12.ceil
    self.complaints                     = self.record.population * 0.005
    self.economy_affected_pct           = 0.2
    self.traffic_speed                  = self.record.currency == "USD" || self.record.currency == "GBP" ? 15 : 25
    self.vehicles_on_road               = self.record.population * 0.50
    self.infrastructure_wear_costs      = self.ccy(self.record.maintenance_budget * 0.04)
    self.vegetation_replacement_costs   = self.ccy(self.infrastructure_wear_costs * 0.02)
    self.co2_diesel                     = self.record.currency == "USD" ? 22.2 : self.record.currency == "GBP" ? 22.2 / 0.8327.to_f : 22.2 * 0.4536.to_f / 3.7854
    self.co2_gas                        = self.record.currency == "USD" ? 19.4 : self.record.currency == "GBP" ? 19.4 / 0.8327.to_f : 19.4 * 0.4536.to_f / 3.7854
    self.emergency_vehicles_event       = self.accidents_per_event * 2
    self.toll_roads_vehicles            = self.vehicles_on_road * 0.04
  end
end

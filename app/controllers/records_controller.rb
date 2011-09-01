class RecordsController < ApplicationController
  layout "front_page", :only => [:new]
  layout "spread", :only => [:index]
  layout "results", :except => [:new, :index, :destroy]

  before_filter :get_units, :except => [:create, :update, :new, :index, :destroy, :export_to_csv, :legal]
  before_filter :get_record, :except => [:create, :new, :index, :destroy, :export_to_csv, :legal]

  def new
    @record = Record.new(:assumptions_setting => AssumptionsSetting.new, :contactable => true)
    @sample = Record.find(:first)
    render :layout => "front_page"
    @title = nil
  end

  def show
    respond_to do |type|
      type.html
      type.json {render :json => @record.to_json(:include => :assumptions_setting)}
    end
  end

  def user_savings
    @title = "Monetary User Benefits"
    @nav = 1
    @sub_nav = 1
  end

  def user_reductions
    @title = "Non-Monetary User Benefits"
    @nav = 1
    @sub_nav = 2
  end

  def community_savings
    @title = "Monetary Community Benefits"
    @nav = 2
    @sub_nav = 1
  end

  def community_reductions
    @title = "Non-Monetary Community Benefits"
    @nav = 2
    @sub_nav = 2
  end

  def other_benefits
    @title = "Other Benefits"
    @nav = 3
  end

  def summary
    @title = "Results Summary"
    @nav = 4
  end

  def all
    @title = "All Benefits"
    @nav = 5
  end

  def edit
    @title = "Edit Assumptions"
    @nav = 6
    respond_to do |type|
      type.html
      type.json {render :json => @record.to_json(:include => :assumptions_setting)}
    end
  end

  def create
    @record = Record.create(params[:record])

    if @record.save
      redirect_to summary_path(@record)
    else
      flash.now[:failure] = "Please fill all fields."
      render "new", :layout => "front_page"
    end
  end

  def update
    if @record.update_attributes!(params[:record])
      respond_to do |format|
        format.html { redirect_to(@record)  }
        format.json { render :nothing =>  true }
      end
    else
      respond_to do |format|
        format.html { render :action  => :edit } # edit.html.erb
        format.json { render :nothing =>  true }
      end
    end
  end

  def index
    @records = Record.find(:all, :order => "organization asc")
    render :layout => "spread"
    @title = "Record Index"
  end

  def export_to_csv
    require 'fastercsv'
    @records = Record.find(:all, :order => "organization asc")
    csv_string = FasterCSV.generate do |csv|
        # header row
      csv << [
        "Name",
        "Organization",
        "Contact Permission",
        "Phone",
        "Email",
        "Currency",
        "Labor Time Savings",
        "Material Savings",
        "Maintenance and Wear Savings",
        "Increased Revenue",
        "Total Efficiency Savings",
        "Percent Budget Saved",
        "Increased Value per Station",
        "Weather Events",
        "RWIS Stations",
        "Maintenance Budget",
        "Treatment Vehicles",
        "Treatment Distance",
        "Routes",
        "Cleanup Distance",
        "Dry Material Use",
        "Wet Material Use",
        "Population",
        "Tolls",
        "Treatments",
        "Decision Maker Rate",
        "Driver Rate",
        "Complaint Labor Cost",
        "Regions",
        "Decision Time",
        "Drivers",
        "Decision Makers",
        "Stress Absences",
        "IT Labor Costs",
        "IT Hardware Costs",
        "Vehicle MPG",
        "Fuel Cost",
        "Fleet Cleaning",
        "Fleet Servicing",
        "Equipment Replacement Costs",
        "Dry Material Cost",
        "Wet Material Cost",
        "Cleanup Time per Mile",
        "Treatment Hours per Driver",
        "Cleanup Miles per Route",
        "Cleanup Time per Route",
        "Cost per Major Accident",
        "Cost per Fatality",
        "Total Local Economy",
        "Community Fuel Economy",
        "Distance per Vehicle",
        "Litigation Cost Accident",
        "Litigation Cost Fatality",
        "Accidents per Event",
        "Fatalities",
        "Complaints",
        "Economy Affected Percentage",
        "Average Traffic Speed",
        "Vehicles on Road",
        "Infrastructure Wear Costs",
        "Vegetation Replacement Costs",
        "CO2 Diesel",
        "CO2 Gasoline",
        "Toll Roads Vehicles",
        "Emergency Vehicles",
        "decision time savings",
        "treatment labor usage savings",
        "reduced stress absences savings",
        "dry material savings",
        "wet material savings",
        "cleanup labor savings",
        "vehicle maintenance savings",
        "fuel consumption savings",
        "wear infrastructure savings",
        "it hardware savings",
        "it labor savings",
        "toll revenue increase",
        "total efficiency savings",
        "decision time reduction",
        "driving time reduction",
        "stress absences reduction",
        "dry material reduction",
        "wet material reduction",
        "cleanup labor time reduction",
        "required vehicles reduction",
        "operation people reduction",
        "driven lane miles reduction",
        "it labor reduction",
        "toll vehicles increase",
        "complaint savings",
        "litigation savings",
        "total publicity savings",
        "complaints reduction",
        "lawsuits reduction",
        "accident savings",
        "fatality savings",
        "total safety savings",
        "accidents reduction",
        "fatalities reduction",
        "emergency response time reduction",
        "local economy losses reduction",
        "total community savings",
        "average speed increase",
        "road vehicles increase",
        "community time savings",
        "pollution savings",
        "co2 community cost avoidance",
        "veh infrastructure savings",
        "environmental savings",
        "total environment savings",
        "road treatment materials reduction",
        "ghg reduction",
        "polluting emissions reduction",
        "Created at"
      ]

      @records.each do |record|
        csv << [
          record.name,
          record.organization,
          record.contactable,
          record.phone,
          record.email,
          record.currency,
          record.labor_time_savings,
          record.material_savings,
          record.maintenance_wear_savings,
          record.increased_revenue,
          record.total_efficiency_savings,
          record.percent_budget_saved,
          record.increased_value_per_station,
          record.events,
          record.stations,
          record.maintenance_budget,
          record.treatment_vehicles,
          record.treatment_miles,
          record.routes,
          record.cleanup_miles,
          record.dry_material_use,
          record.wet_material_use,
          record.population,
          record.assumptions_setting.tolls_per_vehicle,
          record.assumptions_setting.treatments_per_year,
          record.assumptions_setting.decision_maker_rate,
          record.assumptions_setting.driver_rate,
          record.assumptions_setting.complaint_labor_cost,
          record.assumptions_setting.regions,
          record.assumptions_setting.decision_hrs,
          record.assumptions_setting.drivers,
          record.assumptions_setting.decision_makers,
          record.assumptions_setting.stress_absences,
          record.assumptions_setting.it_labor_costs,
          record.assumptions_setting.it_hardware_costs,
          record.assumptions_setting.vehicle_mpg,
          record.assumptions_setting.fuel_cost,
          record.assumptions_setting.fleet_cleaning,
          record.assumptions_setting.fleet_servicing,
          record.assumptions_setting.equipment_replacement_costs,
          record.assumptions_setting.dry_material_cost,
          record.assumptions_setting.wet_material_cost,
          record.assumptions_setting.cleanup_time_per_mile,
          record.assumptions_setting.treatment_hrs_per_event_driver,
          record.assumptions_setting.cleanup_miles_per_route,
          record.assumptions_setting.cleanup_hrs_per_route,
          record.assumptions_setting.cost_per_major_accident,
          record.assumptions_setting.cost_per_fatality,
          record.assumptions_setting.total_local_economy,
          record.assumptions_setting.community_fuel_economy,
          record.assumptions_setting.miles_per_vehicle,
          record.assumptions_setting.litigation_cost_accident,
          record.assumptions_setting.litigation_cost_fatality,
          record.assumptions_setting.accidents_per_event,
          record.assumptions_setting.fatalities,
          record.assumptions_setting.complaints,
          record.assumptions_setting.economy_affected_pct,
          record.assumptions_setting.traffic_speed,
          record.assumptions_setting.vehicles_on_road,
          record.assumptions_setting.infrastructure_wear_costs,
          record.assumptions_setting.vegetation_replacement_costs,
          record.assumptions_setting.co2_diesel,
          record.assumptions_setting.co2_gas,
          record.assumptions_setting.toll_roads_vehicles,
          record.assumptions_setting.emergency_vehicles_event,
          record.decision_time_savings,
          record.treatment_labor_usage_savings,
          record.reduced_stress_absences_savings,
          record.dry_material_savings,
          record.wet_material_savings,
          record.cleanup_labor_savings,
          record.vehicle_maintenance_savings,
          record.fuel_consumption_savings,
          record.wear_infrastructure_savings,
          record.it_hardware_savings,
          record.it_labor_savings,
          record.toll_revenue_increase,
          record.total_efficiency_savings,
          record.decision_time_reduction,
          record.driving_time_reduction,
          record.stress_absences_reduction,
          record.dry_material_reduction,
          record.wet_material_reduction,
          record.cleanup_labor_time_reduction,
          record.required_vehicles_reduction,
          record.operation_people_reduction,
          record.driven_lane_miles_reduction,
          record.it_labor_reduction,
          record.toll_vehicles_increase,
          record.complaint_savings,
          record.litigation_savings,
          record.total_publicity_savings,
          record.complaints_reduction,
          record.lawsuits_reduction,
          record.accident_savings,
          record.fatality_savings,
          record.total_safety_savings,
          record.accidents_reduction,
          record.fatalities_reduction,
          record.emergency_response_time_reduction,
          record.local_economy_losses_reduction,
          record.total_community_savings,
          record.average_speed_increase,
          record.road_vehicles_increase,
          record.community_time_savings,
          record.pollution_savings,
          record.co2_community_cost_avoidance,
          record.veh_infrastructure_savings,
          record.environmental_savings,
          record.total_environment_savings,
          record.road_treatment_materials_reduction,
          record.ghg_reduction,
          record.polluting_emissions_reduction,
          record.created_at
        ]
      end
    end

    # add byte order mark
    require 'iconv'
    csv_string = "\377\376" + Iconv.conv("utf-16le", "utf-8", csv_string)

    send_data csv_string, :type => 'text/csv; charset=utf-16',
                          :filename => "roaddss-calc-records.csv"
  end

  def destroy
    Record.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    @records = Record.all
    redirect_to(:action =>'index')
  end

  def recalculate_assumptions
    @record.assumptions_setting.default_values
    @record.save
    flash[:success] = "Assumptions recalculated"
    redirect_to edit_record_path(@record)
  end

  def summary_report
    html = render_to_string(:layout => 'results' , :action => "summary.html.erb")
    kit = PDFKit.new(html)
    kit.stylesheets << 'public/stylesheets/email-export.css' << 'public/stylesheets/compiled/print.css'
    pdf = kit.to_pdf
    ReportMailer.summary_report(@record, pdf).deliver
    flash[:success] = "Email sent successfully"
    redirect_to summary_path(@record)
  end

  def all_report
    html = render_to_string(:layout => 'results' , :action => "all.html.erb")
    kit = PDFKit.new(html)
    kit.stylesheets << 'public/stylesheets/email-export.css' << 'public/stylesheets/compiled/print.css'
    pdf = kit.to_pdf
    ReportMailer.all_report(@record, pdf).deliver
    flash[:success] = "Email sent successfully"
    redirect_to all_path(@record)
  end

  def get_record
    @record = Record.find(params[:id])
  end

  def get_units
    @record = Record.find(params[:id])
    @time_unit = "Hours"
    @currency_unit = @record.currency
    if @record.currency == "USD"
      @currency_sym = "$"
      @distance_unit = "Miles"
      @fuel_economy_unit = "MPG"
      @volume_unit = "Gals"
      @mass_unit = "Lbs"
      @delimiter = ","
      @separator = "."
    elsif @record.currency == "GBP"
      @currency_sym = "&pound;"
      @distance_unit = "Miles"
      @fuel_economy_unit = "MPG"
      @volume_unit = "Gals"
      @mass_unit = "Lbs"
      @delimiter = ","
      @separator = "."
    elsif @record.currency == "EUR"
      @currency_sym = "&euro;"
      @distance_unit = "Km"
      @fuel_economy_unit = "Liters / 100 Km"
      @volume_unit = "Liters"
      @mass_unit = "Kg"
      @delimiter = "."
      @separator = ","
    elsif @record.currency == "CAD"
      @currency_sym = "$"
      @distance_unit = "Km"
      @fuel_economy_unit = "Liters / 100 Km"
      @volume_unit = "Liters"
      @mass_unit = "Kg"
      @delimiter = ","
      @separator = "."
    end
  end

  def legal
    @title = "Value Calculator Usage and Privacy Agreement"
    render :layout => "contact"
  end
end

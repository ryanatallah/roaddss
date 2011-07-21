class RecordsController < ApplicationController
  layout "front_page", :only => [:new]
  layout "spread", :only => [:index]
  layout "results", :except => [:new, :index, :destroy]

  before_filter :get_units, :except => [:create, :update, :new, :index, :destroy, :export_to_csv]
  before_filter :get_record, :except => [:create, :new, :index, :destroy, :export_to_csv]

  def new
    @record = Record.new(:assumptions_setting => AssumptionsSetting.new)
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
      redirect_to user_savings_path(@record)
    else
      redirect_to root_path
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
    @records = Record.all
    render :layout => "spread"
    @title = "Record Index"
  end

  def export_to_csv
    @records = Record.all
    csv_string = FasterCSV.generate do |csv|
        # header row
      csv << [
        "Name",
        "Organization",
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
        "Tolls"
      ]

      @records.each do |record|
        csv << [
          record.name,
          record.organization,
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
          record.assumptions_setting.tolls_per_vehicle
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
end

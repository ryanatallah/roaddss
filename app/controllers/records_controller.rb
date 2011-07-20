class RecordsController < ApplicationController
  layout "front_page", :only => [:new]
  layout "results", :except => [:new, :index]

  before_filter :get_units, :except => [:create, :update, :new, :index]
  before_filter :get_record, :except => [:create, :new, :index]

  def new
    @record = Record.new(:assumptions_setting => AssumptionsSetting.new)
    render :layout => "front_page"
    @title = nil
  end

  def index
    @records = Record.all
    @title = "Record Index"
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

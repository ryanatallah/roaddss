class SupportsController < ApplicationController
  layout "contact"

  def new
    # id is required to deal with form
    @support = Support.new(:id => 1)
    if request.fullpath.include?("records")
      @record = Record.find(params[:id])
    end
  end

  def create
    @support = Support.new(params[:support])
    if @support.save
      flash[:success] = "Email sent successfully"
      redirect_to root_path
    else
      flash[:error] = "You must fill all fields."
      render 'new'
    end
  end
end

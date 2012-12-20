class ServiceTypesController < ApplicationController
  def index
    @service_types = ServiceType.all
  end
  
  def show
    @service_type = ServiceType.find(params[:id])
  end
  
  def new
    @service_type = ServiceType.new
  end
  
  def create
    @service_type = ServiceType.new(params[:service_type])
    if @service_type.save
      flash[:notice] = "Successfully created service type."
      redirect_to @service_type
    else
      render :action => 'new'
    end
  end
  
  def edit
    @service_type = ServiceType.find(params[:id])
  end
  
  def update
    @service_type = ServiceType.find(params[:id])
    if @service_type.update_attributes(params[:service_type])
      flash[:notice] = "Successfully updated service type."
      redirect_to @service_type
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @service_type = ServiceType.find(params[:id])
    @service_type.destroy
    flash[:notice] = "Successfully destroyed service type."
    redirect_to service_types_url
  end
end

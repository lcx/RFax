class DidsController < ApplicationController
  def index
    @dids = Did.all
  end
  
  def show
    @did = Did.find(params[:id])
  end
  
  def new
    @did = Did.new
  end
  
  def create
    @did = Did.new(params[:did])
    if @did.save
      flash[:notice] = "Successfully created did."
      redirect_to @did
    else
      render :action => 'new'
    end
  end
  
  def edit
    @did = Did.find(params[:id])
  end
  
  def update
    @did = Did.find(params[:id])
    if @did.update_attributes(params[:did])
      flash[:notice] = "Successfully updated did."
      redirect_to @did
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @did = Did.find(params[:id])
    @did.destroy
    flash[:notice] = "Successfully destroyed did."
    redirect_to dids_url
  end
end

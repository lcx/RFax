class FaxesController < ApplicationController
  def index
    @faxes = Fax.all
  end
  
  def show
    @fax = Fax.find(params[:id])
  end
  
  def new
    @fax = Fax.new
  end
  
  def create
    @fax = Fax.new(params[:fax])
    if @fax.save
      flash[:notice] = "Successfully created fax."
      redirect_to @fax
    else
      render :action => 'new'
    end
  end
  
  def edit
    @fax = Fax.find(params[:id])
  end
  
  def update
    @fax = Fax.find(params[:id])
    if @fax.update_attributes(params[:fax])
      flash[:notice] = "Successfully updated fax."
      redirect_to @fax
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @fax = Fax.find(params[:id])
    @fax.destroy
    flash[:notice] = "Successfully destroyed fax."
    redirect_to faxes_url
  end
end

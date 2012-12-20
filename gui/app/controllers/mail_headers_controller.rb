class MailHeadersController < ApplicationController
  def index
    @mail_headers = MailHeader.all
  end
  
  def show
    @mail_header = MailHeader.find(params[:id])
  end
  
  def new
    @mail_header = MailHeader.new
  end
  
  def create
    @mail_header = MailHeader.new(params[:mail_header])
    if @mail_header.save
      flash[:notice] = "Successfully created mail header."
      redirect_to @mail_header
    else
      render :action => 'new'
    end
  end
  
  def edit
    @mail_header = MailHeader.find(params[:id])
  end
  
  def update
    @mail_header = MailHeader.find(params[:id])
    if @mail_header.update_attributes(params[:mail_header])
      flash[:notice] = "Successfully updated mail header."
      redirect_to @mail_header
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @mail_header = MailHeader.find(params[:id])
    @mail_header.destroy
    flash[:notice] = "Successfully destroyed mail header."
    redirect_to mail_headers_url
  end
end

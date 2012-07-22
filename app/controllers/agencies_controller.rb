class AgenciesController < ApplicationController
  def index
  	@agencies = Agency.order("name").all

    respond_to do |format|
      format.html
      format.json { render :json => @agencies }
      format.xml  { render :xml => @agencies }
    end
  end

  def show
  	@agency = Agency.find_by_oba_id(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @agency }
      format.xml  { render :xml => @agency }
    end
  end

  def show_otp
  	@agency = Agency.find_by_code(params[:code])

    respond_to do |format|
      format.html { render 'show' }
      format.json { render :json => @agency }
      format.xml  { render :xml => @agency }
    end
  end
  def edit
  	@agency = Agency.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @agency }
      format.xml  { render :xml => @agency }
    end
  end
  def create
    puts "create agencies blocked. #{params[:name]}"
  end

  def destroy
    puts "Destroy agencies blocked"
  end
  def update
    puts "Update agencies blocked"
  end
end

class AgenciesController < ApplicationController
  def index
  	@agencies = Agency.order("name").all
  end

  def show
  	@agency = Agency.find_by_oba_id(params[:id])
  end

  def show_otp
  	@agency = Agency.find_by_code(params[:code])
  	render 'show'
  end
  def edit
  	@agency = Agency.find(params[:id])
  end
end

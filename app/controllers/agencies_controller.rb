class AgenciesController < ApplicationController
  def index
  	@agencies = Agency.order("name").all
  end

  def show
  	@agency = Agency.find(params[:id])
  end

  def edit
  	@agency = Agency.find(params[:id])
  end
end

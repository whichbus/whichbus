class RoutesController < ApplicationController
  def index
  	@routes = Route.order("name").all
  end

  def show
	@route = Route.find_by_oba_id(params[:id])
  end

  def show_otp
  	@route = Route.find_by_agency_code_and_code(params[:agency], params[:code])
  	render 'show'
  end

  def edit
  	@route = Route.find(params[:id])
  end
end

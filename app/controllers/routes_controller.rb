class RoutesController < ApplicationController
  def index
  	@routes = Route.order("name").all
  end

  def show
  	@route = Route.find(params[:id])
  end

  def edit
  	@route = Route.find(params[:id])
  end
end

class StopsController < ApplicationController
  def index
  	@stops = Stop.order("name").all
  end

  def show
  	@stop = Stop.find(params[:id])
  end

  def edit
  	@stop = Stop.find(params[:id])
  end
end

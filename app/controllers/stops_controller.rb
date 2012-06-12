class StopsController < ApplicationController
  def index
  	@stops = Stop.order("name").all
  end

  def show
  	@stop = Stop.find_by_oba_id(params[:id])
  end

  def show_otp
  	@stop = Stop.find_by_agency_code_and_code(params[:agency], params[:code])
  	render 'show'
  end

  def edit
  	@stop = Stop.find(params[:id])
  end
end

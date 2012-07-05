class StopsController < ApplicationController
	def index
		# split stops into groups of 100, served up using page parameter
		@stops = Stop.order("name").limit(100).offset(params.has_key?('page') ? params[:page].to_i * 100 : 0)

		respond_to do |format|
			format.html
			format.json { render :json => @stops }
			format.xml  { render :xml => @stops }
		end
	end

	def show
		@stop = Stop.find_by_oba_id(params[:id])

		respond_to do |format|
			format.html
			format.json { render :json => @stop, :include => {:routes => { :only => [:oba_id, :name] } } }
			format.xml  { render :xml => @stop }
		end
	end

	def show_otp
		@stop = Stop.find_by_agency_code_and_code(params[:agency], params[:code])

		respond_to do |format|
			format.html { render 'show' }
			format.json { render :json => @stop }
			format.xml  { render :xml => @stop }
		end
	end

	def create
		puts "create called. #{params[:name]}"
	end

	def edit
		@stop = Stop.find_by_oba_id(params[:id])
	end	

	def routes
		api_page Stop.find_by_oba_id(params[:id]).routes
	end

	def schedules
		api_page Stop.find_by_oba_id(params[:id]).schedules
	end

	def arrivals
		api_page Stop.find_by_oba_id(params[:id]).arrivals
	end

	def arrivals_otp
		api_page Stop.find_by_agency_code_and_code(params[:agency], params[:code]).arrivals
	end
end

class ApplicationController < ActionController::Base
	protect_from_forgery

	before_filter :cor

	def cor
		headers["Access-Control-Allow-Origin"]  = "whichbus-spine.herokuapp.com"
		headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
		headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")
		head(:ok) if request.request_method == "OPTIONS"
	end

	# a helper to set up an API page in one line
	def api_page(data)
		respond_to do |format|
			# format.html
			format.json { render :json => data }
			format.xml  { render :xml => data }
		end
	end

	def index
		render :layout => 'transit'
	end

	def search
		query = "%#{params[:query]}%"
		@agencies = Agency.where("code like ? OR name like ?", query, query)
		@routes = Route.where("code like ? OR name like ?", query, query)
		@stops = Stop.where("code like ? OR name like ?", query, query)
		render 'splash' if params[:query].nil?
	end

	def otp
		api_page API.open_trip_planner(params[:method], params)
	end

	def oba
		api_page API.one_bus_away(params[:method], params[:id], params)
	end
end

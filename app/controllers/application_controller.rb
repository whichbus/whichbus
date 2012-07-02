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
		unless params[:query].nil? or params[:query].blank?
			# enter a stop ID to jump straight to it
			if params[:query].to_i > 1000
				@stop = Stop.find_by_code(params[:query])
				redirect_to stop_path(@stop.oba_id) if @stop
			end

			# sanitize query parameters
			query = "%#{params[:query]}%"
			limit = params[:limit] or 100
			offset = params[:page].to_i * limit.to_i or 0

			# generic search looks at all models using SQL like operator
			@agencies = Agency.where("code like ? OR name like ?", query, query)
			@routes = Route.where("code like ? OR name like ?", query, query).limit(limit).offset(offset)
			@stops = Stop.where("name like ?", query).limit(limit).offset(offset)
		end

		# and it's an API too!
		respond_to do |format|
			format.html { render 'splash' if params[:query].nil? or params[:query].blank? }
			format.json { 
				render :json => {agencies: @agencies, routes: @routes, stops: @stops} 
			}
		end
	end

	def otp
		api_page API.open_trip_planner(params[:method], params)
	end

	def oba
		api_page API.one_bus_away(params[:method], params[:id], params)
	end
end

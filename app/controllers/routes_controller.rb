class RoutesController < ApplicationController
	def index
		@routes = Route.order("name").all

		respond_to do |format|
			format.html
			format.json { render :json => @routes }
			format.xml  { render :xml => @routes }
		end
	end

	def create
		render :json => params
	end

	def show
		@route = Route.find_by_oba_id(params[:id])

		respond_to do |format|
			format.html
			format.json { render :json => @route }
			format.xml  { render :xml => @route }
		end
	end

	def show_otp
		@route = Route.find_by_agency_code_and_code(params[:agency], params[:code])

		respond_to do |format|
			format.html { render 'show' }
			format.json { render :json => @route }
			format.xml  { render :xml => @route }
		end
	end

	def update
		puts params
		render :json => params

		# @route = Route.find(params[:id])

		# respond_to do |format|
		# 	format.html
		# 	format.json { render :json => @route }
		# 	format.xml  { render :xml => @route }
		# end
	end

	def stops
		@route = Route.find_by_oba_id(params[:id])
		@stops = @route.stops

		respond_to do |format|
			format.json { render :json => @stops }
			format.xml  { render :xml => @stops }
		end
	end

	def trips
		api_page Route.find_by_oba_id(params[:id]).trips
	end
end

require 'net/http'
require 'open-uri'

class PagesController < ApplicationController
	@@data_count = 0

	def index
		render :layout => 'spine-app'
	end

	def search
		query = "%#{params[:query]}%"
		@agencies = Agency.where("code like ? OR name like ?", query, query)
		@routes = Route.where("code like ? OR name like ?", query, query)
		@stops = Stop.where("code like ? OR name like ?", query, query)
		render 'splash' if params[:query].nil?
	end

	def otp
		@data = API.open_trip_planner(params[:method], params)['routes']

		respond_to do |format|
			format.json { render :json => @data }
			format.xml  { render :xml => @data }
		end
	end

	def oba
		@data = API.one_bus_away(params[:method], params[:id], params)

		respond_to do |format|
			format.json { render :json => @data }
			format.xml  { render :xml => @data }
		end
	end
end

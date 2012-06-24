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
		api_page API.open_trip_planner(params[:method], params)['routes']
	end

	def oba
		api_page API.one_bus_away(params[:method], params[:id], params)
	end
end

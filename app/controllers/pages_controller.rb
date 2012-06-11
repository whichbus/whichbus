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
	end

	def otp
		url = "http://otp.whichb.us:8080/opentripplanner-api-webapp/ws/transit/#{params[:method]}"
		if params.has_key?("agency")
			url += "?agency=#{params[:agency]}&id=#{params[:id]}"
		elsif params.has_key?("lat")
			url += "?lat=#{params[:lat]}&lon=#{params[:lon]}"
		end
		@data = get_json(url)['routes']
		puts @data

		respond_to do |format|
			format.json { render :json => @data }
			format.xml  { render :xml => @data }
		end
	end

	def api
		url = "http://3xb6.localtunnel.com/#{params[:method]}"
		if params.has_key?("agency")
			url += "/#{params[:agency]}/#{params[:id]}"
		elsif params.has_key?("lat")
			url += "?lat=#{params[:lat]}&lon=#{params[:lon]}"
		end
		@data = get_json(url)

		respond_to do |format|
			format.json { render :json => @data }
			format.xml  { render :xml => @data }
		end
	end
	
	def get_json(url, verbose=false)
		@@data_count += 1
		puts "JSON REQUEST #{@@data_count}: #{url}"

		JSON.parse(open(url, 'Content-Type' => 'application/json').read)
	end
end

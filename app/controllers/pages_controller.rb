require 'net/http'
require 'open-uri'

class PagesController < ApplicationController
	
	def index
		render :layout => 'spine-app'
	end
end

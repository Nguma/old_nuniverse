class LocationsController < ApplicationController 
	
	protect_from_forgery :except => [:suggest]
	after_filter :update_session, :only => [:show]
	
	def find
			@locations = []# Location.find(:all, :conditions => ['name like ? OR full_address like ?', "#{params[:name]}%", "%#{params[:address]}%"])
		sll = Graticule.service(:host_ip).new.locate(request.remote_ip).coordinates.join(',') rescue "40.746497,-74.009447"
		query = params[:location][:address]
		@google_suggestions = Googleizer::Request.new(query, :mode => "local").response(:sll => sll, :rsz => "small").results

		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def show
		
	end
	
	def new
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def create
		
		if params[:location][:latlng]
		
		else
			geolocate(params[:name])
		end
		
		
		@location = Location.create(
			:name => params[:name],
			:full_address => params[:address],
			:country_id => params[:country_id],
			:latlng => params[:latlng])
			
		@location
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	
	def suggest
		geolocate(params[:location][:])
	end
	
	
end
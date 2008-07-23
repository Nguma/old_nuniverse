class NuniverseController < ApplicationController
	
	def index
	end
	
	def show
		session[:path] = params[:path] || session[:path]
		session[:perspective] = params[:perspective] || nil
		
		@nuniverse = Nuniverse.new(
			:path => session[:path], 
			:user => current_user
		)
		@section = Section.new (
			:path => session[:path], 
			:kind => params[:kind] || nil,
			:page => params[:page] || 1,
			:pespective => session[:perspective],
			:user => current_user
		 )
		
	end
	
	def section
		if params[:path]
			session[:path] = params[:path]
			params[:perspective] ||= session[:perspective]
		else
			params[:path] = session[:path]
			params[:no_wrap] = 1
			params[:perspective] ||= session[:perspective]
		end
		session[:perspective] = params[:perspective]
		@section = Section.new(params)
	end
	
	def overview
		@nuniverse = Nuniverse.new(:path => params[:path], :user => current_user)
	end
	
end

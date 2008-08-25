class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def show
		session[:path] = params[:path] || session[:path]
		session[:perspective] = params[:perspective] || nil
		session[:kind] = params[:kind] || nil
		
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
			# params[:no_wrap] = 1 if params[:path] == session[:path]
			session[:path] = params[:path]
			
		else
			params[:path] = session[:path]
			# params[:no_wrap] = 1
			
		end
		params[:perspective] ||= session[:perspective]
		
		params[:kind] ||= session[:kind]
		session[:kind] = params[:kind]
		session[:perspective] = params[:perspective] 
		@section = Section.new(params)
	end
	
	def overview
		session[:path] = params[:path] || session[:path]
		session[:perspective] = params[:perspective] || nil
		
		@section = Section.new(
			:path => params[:path], 
			:user => current_user,
			:pespective => session[:perspective],
			:degree => "all"
		)
	end
	
	def connect
		kind_label = Nuniverse::Kind.scan_entry(params[:query])
		kind = kind_label[0] 
		label = kind_label[1] rescue params[:query]
		
		
		
		# raise Nuniverse::Kind.all.join('|').inspect
		
		# raise Tag.with_label_like(label).with_kind_like(kind).inspect
		existing_tags = Tag.with_label_like(label).with_kind_like(kind)
		
		if existing_tags.empty?
			
			@tag = Tag.create(
				:label => label,
				:kind => kind || 'topic',
				:description => "",
				:data => ""
			)
		else
			@tag = existing_tags[0]
		end
		raise "No matching or created tag, cannot connect" if @tag.nil?
		@tagging = Tagging.create(
			:subject_id => current_user.tag.id,
			:object_id => @tag.id,
			:user_id => current_user.id,
			:path => session[:path])
			
		# gum = {}
		# 		gumies = params[:query].scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/)
		# 			unless gumies.empty?
		# 				params[:label] = gumies[0][1]
		# 				params[:kind]    = gumies[0][0]
		# 				gumies.shift
		# 				gumies.each do |gumi|
		# 					gum[gumi[0]] = gumi[1]
		# 				end
		# 			end
		# 			params[:description] ||= gum.delete('description')
		# 			params[:url]         ||= gum.delete('url')
		# 			params[:service]     ||= gum.delete('service')
		# 			
		# 			@tagging = Tag.connect(
		# 				:label 	    => params[:label],
		# 				:kind			    => params[:kind],
		# 				:path			    => session[:path],
		# 				:restricted   => params[:restricted],
		# 				:description  => params[:description] || "",
		# 				:url          => params[:url],
		# 				:service      => params[:service],
		# 				:gum          => gum,
		# 				:relationship => params[:relationship],
		# 				:user_id	    => current_user.id
		# 			)
		render :layout => false
	end
	
	
	
	
end

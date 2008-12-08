class ConnectionsController < ApplicationController
	
	before_filter :find_connection, :except => [:connect]
	
	def connect
		@object = Tag.find(params[:object])
		@subject = Tag.find(params[:subject]) rescue create_subject
		@connection_from = Connection.find_or_create(:subject => @subject, :object => @object)
		@connection_to = Connection.find_or_create(:subject => @object, :object => @subject)
		params[:tags] ||= @subject.property('tags').blank? ? @subject.kind :  @subject.property('tags')
		if params[:tags] != "nuniverse"
			@subject.tag_with(params[:tags].split(','))
		end
		
		respond_to do |f|
			f.html {}
			f.js {}
		end

	end
	
	
	def disconnect
		@connections = [@connection] 
		@connections << @connection.twin unless @connection.twin.nil?
		
		@connections.flatten.each do |c|
			c.destroy
		end
		redirect_back_or_default('/')
	end
	
	def preview
		@connections = @connection.connections.paginate(:per_page => 10, :page => 1)
	end
	
	def tag
		@connection.subject.tag_with(params[:kinds].split(',')) unless params[:kinds].nil?
		@connection.tag_with(params[:tags].split(','))
	end
	
	def edit
		
	end
	
	def add_to_favorites
		@fav = Favorite.new
		@fav.user_id = current_user.id
		@fav.connection_id = @connection.id
		@fav.save
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def remove_from_favorites
		@fav = Favorite.find(:first, :conditions => ['user_id = ? AND connection_id = ?',current_user.id, @connection.id]) 
		@fav.destroy
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	protected
	
	def find_connection
		@connection = Connection.find(params[:id])
	end
	
	def create_subject
		
		case params[:kind]
		when "address"
			params[:label] = @subject.property('address')
		when "image"
		
		when "bookmark"

			if params[:url].match('en.wikipedia.org/wiki/')
				t = params[:url].gsub(/.*\/wiki/,'/wiki')
				doc = Nuniverse.get_content_from_wikipedia(t)
				params[:description] = Nuniverse.wikipedia_description(doc) 
				params[:input] = "#{(doc/:h1).first.inner_html.to_s} on Wikipedia"
				@object.description = params[:description] if @object.description.nil?
				@object.replace_property('wikipedia_url',t)
				img = (doc/'table.infobox'/:img).first
				unless (img.nil? || img.to_s.match(/Replace_this_image|Flag_of/))
					image = Tag.find_or_create(:label => img.attributes['src'].split('/').last, :kind => 'image', :url => img.attributes['src'])
					image.add_image(:source_url => img.attributes['src'])
					image.connect_with(@object, :user => current_user)
					image.tag_with('image')			
				end
			else
				doc = Hpricot open( params[:url])
				params[:input] = (doc/:title).first.inner_html.to_s.blank? ? params[:url] : (doc/:title).first.inner_html.to_s

				params[:description] ||= (doc/:p).first.inner_html.to_s rescue ""
			end
			
		else
			params[:input] = params[:description].split(/\n/)[0] if params[:input].blank?
		end
		
		if params[:kind] == "nuniverse"
			
			@subject = Tag.create(
			:label => params[:input], 
			:kind => params[:kind], 
			:url => params[:url], 
			:data => params[:data], 
			:description => params[:description], 
			:service => params[:service]
			)
		else
		@subject = Tag.find_or_create(
				:label => params[:input], 
				:kind => params[:kind], 
				:url => params[:url], 
				:data => params[:data], 
				:description => params[:description], 
				:service => params[:service]
			)
		end
		if params[:kind] == "image"
			@subject.add_image( :source_url => params[:input], :uploaded_data => params[:uploaded_data]) 
			@subject.label = @subject.image.filename.gsub(/\-|\_/,' ')
			@subject.save
		end
		
		if params[:data] && !@subject.property('tel').blank?
			tel = Tag.find_or_create(:label => @subject.property('tel'), :kind => 'telephone')
			tel.connect_with(@subject, :as => "telephone number")
		end
	
		
		@subject
				
		
			# if @kind == 'bookmark'  && @subject.url.match('en.wikipedia.org/wiki/')
			# 			@subject.label = @subject.label.gsub(/\,\s+the free encyclopedia/, "")
			# 			@subject.save
			# 				t = @subject.url.gsub(/.*\/wiki/,'/wiki')
			# 
			# 				@tag.replace_property('wikipedia_url',t)
			# 				wiki_content = Nuniverse.get_content_from_wikipedia(t)
			# 				
			# 				@tag.description = Nuniverse.wikipedia_description(wiki_content) if @tag.description.nil?
			# 
			# 				img = (wiki_content/'table.infobox'/:img).first
			# 				unless (img.nil? || img.to_s.match(/Replace_this_image|Flag_of/))
			# 					image = Tag.find_or_create(:label => img.attributes['src'].split('/').last, :kind => 'image', :url => img.attributes['src'])
			# 					@image = image.add_image(:source_url => img.attributes['src'])
			# 					image.connect_with(@tag, :user => current_user)
			# 								
			# 				end
			# 				@tag.save
			# 				
			# 		end

		

	end
	
end
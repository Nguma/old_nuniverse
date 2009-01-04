class ConnectionsController < ApplicationController
	
	before_filter :find_connection, :except => [:connect, :new, :create]
	
	def new
		@connection = Connection.new(:subject_id => params[:subject_id], :object_id => params[:object_id])
		
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def show
		
	end
	
	def create

		@connection = Connection.find_or_create(params[:connection]) 
		@twin = Connection.find_or_create(:subject_id => @connection.object_id, :object_id => @connection.subject_id)
	
		respond_to do |f|
			f.html { redirect_back_or_default('/') }
			f.js {}
		end
	end
	
	
	def connect
		@object = Tag.find(params[:object])
		@subject = Tag.find(params[:subject]) rescue create_subject
	
		@connection_from = Connection.find_or_create(:subject_id => @subject.id, :object_id => @object.id)
		@connection = @connection_from
		@connection_to = Connection.find_or_create(:subject_id => @object.id, :object_id => @subject.id)
		params[:tags] ||= @subject.property('tags').to_a
		@subject.tag_with(params[:tags].split(','))

		
		respond_to do |f|
			f.html { redirect_back_or_default('/')}
			f.js {}
		end

	end
	
	
	def disconnect
		@connections = [@connection] 
		@connections << @connection.twin unless @connection.twin.nil?
		
		@connections.flatten.each do |c|
			c.destroy
		end
		respond_to do |f|
			f.html { redirect_back_or_default('/')}
			f.js {}
		end
	end
	
	def preview

		@nuniverses = Connection.with_object(@connection.subject).with_subject_kind('nuniverse').paginate(:per_page => 5, :page => 1)
		@users = Connection.with_subject(current_user.users).with_object(@connection.subject).paginate(:per_page => 5, :page => 1)
	
		# @connections = @connection.connections.with_object_kind('nuniverse').paginate(:per_page => 10, :page => 1)
	end
	
	def tag
		@connection.subject.tag_with(params[:kinds].split(',')) unless params[:kinds].nil?
		@connection.tag_with(params[:tags].split(','))
	end
	
	def update
		
		@connection.description = params[:description] if params[:description]
		@tags = params[:tags].split(',')
	
		@connection.taggings.each do |t|
			if !@tags.include?(t.predicate)
				t.destroy
			else
				@tags.reject! {|c| c == t.predicate}
			end
		end
		@connection.tag_with(@tags)
		@connection.save
		
		respond_to do |f|
			f.html {redirect_to @connection.object}
		end
	end
	
	def edit
		
	end
	
	def rate
		@ranking = @connection.rankings.by_user(current_user).first || Ranking.new(:user => current_user)
		@connection.rankings << @ranking
		
		@ranking.score = params[:score].to_i
		@ranking.save
		redirect_back_or_default("/")
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

		when "image"
		
		when "bookmark"
			params[:url] = "http://#{params[:url]}" if params[:url].match("^www")
			if params[:url].match('en.wikipedia.org/wiki/')
				t = params[:url].gsub(/.*\/wiki/,'/wiki')
			
				doc = Nuniversal.get_content_from_wikipedia(Hpricot open(params[:url]))
				params[:description] = Nuniversal.wikipedia_description(doc) 
				params[:input] = "#{(doc/:h1).first.inner_html.to_s} on Wikipedia"
				@object.description = params[:description] if @object.description.nil?
				@object.replace_property('wikipedia_url',t)
				img = (doc/'table.infobox'/:img).first
				# unless (img.nil? || img.to_s.match(/Replace_this_image|Flag_of/))
				# 					image = Tag.find_or_create(:label => img.attributes['src'].split('/').last.gsub(/\-|\_/,' '), :kind => 'image', :url => img.attributes['src'])
				# 					image.add_image(:source_url => img.attributes['src'])
				# 					image.connect_with(@object, :user => current_user)
				# 					image.tag_with('image')			
				# 				end
			else
				doc = Hpricot open(params[:url])
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
			img = @subject.add_image( :source_url => params[:input], :uploaded_data => params[:uploaded_data]) 

			@subject.label = img.filename.gsub(/\-|\_/,' ')
			@subject.save
		end
		
		if params[:data] && !@subject.property('tel').blank?
			tel = Tag.find_or_create(:label => @subject.property('tel'), :kind => 'telephone')
			tel.connect_with(@subject, :as => "telephone number")
		end
	
		
		@subject


	end
	
end
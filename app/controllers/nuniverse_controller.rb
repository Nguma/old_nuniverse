class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def command
		
		@kind = Nuniverse::Kind.match(params[:command]).strip
		@input = params[:input]
		if params[:list]
			@source =  List.labeled(params[:list]).created_by(current_user).first
			@subject = @source.tag if @source && @source.tag
		elsif params[:tagging]
			@source = Tagging.find(params[:tagging])
			@subject = @source.object
		end
			
		@source = current_user if @source.nil?
		@subject = current_user.tag if @subject.nil?		
		
		case @kind
		when "address","tel","zip"
			@subject.replace_property(@kind, @input)
			@subject.save
		
		when "image"
			@source.add_image(:uploaded_data => params[:image_url][:uploaded_data]|| nil, :source_url => @input)
		when "description"
			@source.description = @input
			@source.save
		when "invite"
			@user = User.find(:first, :conditions => ["email = ?",@input])
			if @user.nil?
				@user = User.new(:email => @input, :login => @input, :password => "welcome")
				@user.save
			end
			current_user.invite(:user => @user, :to => @source, :message => params[:extra_input])
		when "list"
			return if @source.is_a?(List)
			List.find_or_create(
				:creator_id => current_user.id,
				:label => Gum.purify(@input),
				:tag_id => @source == current_user ? nil : @source.object.id 
				)
		when "tag", "tags"
			@input.split(",").each do |input|
				@tag = Tag.find_or_create(
					:label => Gum.purify(input), 
					:kind => "tag"
				)
			
				Tagging.find_or_create(
					:owner => current_user,
					:subject_id => @tag.id,
					:object_id => @subject.id,
					:kind => input,
					:description => "#{@subject.label} #{@tag.label}"
				)
			end
		else
			@tag = Tag.find_or_create(
				:label => Gum.purify(@input), 
				:kind => @kind
			) 
			# Nuniverse::Kind.parse(@kind).split("#").each do |kind|
				Tagging.find_or_create( 
										:owner => current_user, 
										:subject_id => @subject.id , 
									 	:object_id => @tag.id, 
										:kind => @kind
									)
			#end
								

		end
	redirect_back_or_default(@source)
	end
	
	
end

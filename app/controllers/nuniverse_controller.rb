class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def command
		
		# gums = Gum.parse(params[:input])
		# 		unless gums.empty?
		# 			@kind = Nuniverse::Kind.match(gums[0][1]).strip
		# 			@input = gums[0][2]
		# 		else
		# 			@input = params[:input]
		# 		end
		
		@kind = Nuniverse::Kind.match(params[:command]).strip
		@input = params[:input]
		
		# Nuniverse::Kind.analyze(@input)
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
			@source.add_image(:source_url => @input)
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
		when "tag"
			
			@tag = Tag.find_or_create(
				:label => Gum.purify(@input), 
				:kind => @kind
			)
			
			Tagging.find_or_create(
				:owner => current_user,
				:subject_id => @subject.id,
				:object_id => @tag.id,
				:kind => @input,
				:description => "#{@subject.label} #{@tag.label}"
			)
		else
			@tag = Tag.find_or_create(
				:label => Gum.purify(@input), 
				:kind => @kind
			) 

			Tagging.find_or_create( 
									:owner => current_user, 
									:subject_id => @subject.id , 
								 	:object_id => @tag.id, 
									:kind => @kind
								)
								

		end
	redirect_back_or_default(@source)
	end
	
	
end

class NuniverseController < ApplicationController
	
	def index
		redirect_to "/my_nuniverse" if logged_in?
	end
	
	def command
		
		gums = Gum.parse(params[:input])
		unless gums.empty?
			@kind = Nuniverse::Kind.match(gums[0][1]).strip
			@input = gums[0][2]
		else
			@input = params[:input]
		end
		
		@source = params[:list] ? List.find(params[:list]) : Tagging.find(params[:tagging])
		@source = @source.nil? ? current_user : @source
		
		case @kind
		when "image"
			@source.add_image(:source_url => @input)
		when "description"
			@tagging.description = @input
			@tagging.save
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
		else
			@tag = Tag.find_or_create(
				:label => Gum.purify(@input), 
				:kind => @kind
			) 

			@kind.split('#').each do |k| 
				t = Tag.find_or_create(
				:label => k,
				:kind => 'kind'
			)
			Tagging.find_or_create( 
									:owner => current_user, 
									:subject_id => @subject.id, 
								 	:object_id => @tag.id, 
									:kind => "tag",
									:description => k
								)
			end
		end
	redirect_back_or_default(@source)
	end
	
	
end

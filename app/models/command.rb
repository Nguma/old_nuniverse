# This class wraps and parses the user command input,
# also defines the available scripting commands
class Command
	
	attr_reader :raw_command, :action, :argument, :input, :current_user, :extra_input
	
	def initialize(current_user, params)
		@input = params[:input]
		@current_user = current_user
		@extra_input = params[:extra_input]
		@image_url = params[:image_url] || nil
		@raw_command = params[:command].downcase.scan(/^(add|email|create|localize|find|search|invite|new)\s?(a\s|to\s|on\s|in\s|at\s)?(new\s)?(.*)?/)[0]
		@action = @raw_command[0].nil? ? @raw_command[2] : @raw_command[0]
		@argument = @raw_command[3].nil? ? nil : Nuniverse::Kind.match(@raw_command[3].gsub(/\sto$/,'')) 
	end
	
	def self.match(action)
		# if action.match(/^(add|create)\s?((a|to)\s)?(new\s)?(.*)/)
		# 			@action = "add"
		# 			@argument = Nuniverse::Kind.match(@full_command[3])
		# 		elsif action.match(/^(google|((find|search)\s(on\s)?google))\s?$/)
		# 		elsif action.match(/^(find|search)\s(on\s)?(.*)/)
		# 		elsif action.match(/^(invite|email)\s(.*)/)
		# 		elsif action.match(/^(localize)\s)(.*)/)
		# 		else
		# 		end
	end
	
	def execute(params)
		case @action
		when "email"
			if to_myself?
				params[:email] = @current_user.email
			else
				params[:email] = @input
			end
			email_user(	:email => params[:email], 
									:current_user => @current_user,
									:content => params[:source], 
									:message => @extra_input
								)
		when "invite"
		when "search", "find"
			search_for(params)
		when "localize"
		when "add","new","create"
			add_content(params)
		end
		
	end
	
	def add_content(params)
			case @argument
			when "image"
				add_image_to(params[:source])
			when "description"
				params[:source].description = @input
				params[:source].save
			when "list", "category"
				List.find_or_create(
					:creator_id => 	@current_user.id,
					:label => Gum.purify(@input),
					:tag_id => subject_is_user?(params[:subject]) ? nil :params[:subject].id
					)
			when "tag", "tags"
				@input.split(",").each do |input|
					add_tag(:subject => params[:subject])
				end
			else
				tag = Tag.find_or_create(
					:label => Gum.purify(@input), 
					:kind => @argument
				) 
				@argument << "##{params[:subject].label}" unless 	subject_is_user?(params[:subject])
				@argument.split("#").each do |kind|
					Tagging.find_or_create( 
											:owner => @current_user, 
											:subject_id => params[:subject].id , 
										 	:object_id => tag.id, 
											:kind => kind
										)
				end
			end
	end
	
	def subject_is_user?(subject)
		subject == @current_user.tag
	end
	
	def to_myself?
		return false if @raw_command[1] != "to" 
		return false if @argument != "myself"
		return true
	end

	def email_user(params)
		user = User.find(:first, :conditions => ["email = ?",params[:email]])
		if user.nil?
			user = User.new(:email => params[:email], :login => params[:email], :password => "welcome")
			user.save
		end
		@current_user.email_to(:user => user, :content => params[:content], :message => params[:message])
	end
	
	def add_image_to(source)
		source.add_image(:uploaded_data => @image_url[:uploaded_data]|| nil, :source_url => @input)
	end
	
	def add_tag(params)
		tag = Tag.find_or_create(
			:label => Gum.purify(@input), 
			:kind => "tag"
		)

		Tagging.find_or_create(
			:owner => @current_user,
			:subject_id => tag.id,
			:object_id => params[:subject].id,
			:kind => @input,
			:description => "#{params[:subject].label} #{tag.label}"
		)	
	end
	
	def search_for(params)

	end

end
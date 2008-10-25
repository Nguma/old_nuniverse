# This class wraps and parses the user command input,
# also defines the available scripting commands
class Command
	
	attr_reader :raw_command, :action, :argument, :input, :current_user, :extra_input, :list, :service
	
	def initialize(current_user, params)
		@input = params[:input]
		@current_user = current_user
		@extra_input = params[:extra_input]
		@image_url = params[:image_url] || nil
		# @raw_command = params[:command].downcase.scan()[0]
		@raw_command = self.match(params[:command].downcase)
	
		# @action = @raw_command[0].nil? ? @raw_command[2] : @raw_command[0]
		# @argument = @raw_command[3].nil? ? nil : Nuniverse::Kind.match(@raw_command[3].gsub(/\sto$/,'')) 
		if @argument
			@list = List.new(:creator => current_user, :label => @argument.split('#').last, :tag_id => params[:tag_id] || nil)
		end
	end
	
	def match(action)
		action = action.gsub('_',' ');
		if m = action.match(/^(add|create|new)\s?((a|to)\s)?(new\s)?(.*)/)
			@action = "add"
			@argument = Nuniverse::Kind.match(m[5]) || "category"
			@service = nil
			return m
		elsif m = action.match(/^make (private|public)/)
			@action = "set_privacy"
			@argument = m[1]
			@service = nil
		elsif m = action.match(/^(find|search)\b(.*)?(\son\s(google|amazon))?$/)
			@action = "find"
			@argument = m[2]
			@service = m[4] || nil
			return m
		elsif m = action.match(/^email\s(.*)\sto$/)
			@action = "email"
			@argument = Nuniverse::Kind.match(m[1])
			@service = nil
			return m
		elsif m = action.match(/^share\s?(.*)\swith$/)
			@action = "share"
			@argument = m[1]
			@service = nil
			return m
		elsif m = action.match(/^(email|edit|invite)\s?(a\s|to\s|on\s|in\s|at\s|for\s)?(new\s)?(.*)?/)
			@action = m[1]
			@argument = m[3]
			@service = nil
			return m
		elsif m = action.match(/^(save|forget)$/)
			@action = m[1]
			@argument = nil
			@service = nil
		else
			return false
		end
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
									:content => @list, 
									:message => @extra_input,
									:perspective => params[:service]
								)
		when "share"
			invite_user(:email => @input, 
									:current_user => @current_user,
									:content => @list, 
									:message => @extra_input,
									:perspective => params[:service]
			)
		when "search", "find"
			
		when "localize"
		when "add","new","create"
			return add_content(params)
		when "edit"
			return edit_content(params)
		when "set_privacy"
			p = @argument == 'public' ? 1 : 0
			params[:tagging].public = p
			return params[:tagging].save
		when "save"
			t = params[:tagging].clone
			t.owner = @current_user
			return t.save
		when "forget"
			# Returned tagging not forcefully the one owned by the current_user. 
			# Have to requery it
			t = Tagging.find(:first, 
					:conditions => ['user_id = ? AND kind = ? AND subject_id = ? AND object_id = ? ',	@current_user,params[:tagging].kind,params[:tagging].subject_id,params[:tagging].object_id])
			t.user_id = 0
			return t.save
		end
		
	end
	
	
	def edit_content(params)
		case @argument
		when "description"
			return add_description(params[:source])
		end
	end
	
	def add_content(params)
			case @argument
			when "image"
				return add_image_to(@list.tag)
			when "description"
				return add_description(params[:source])
			when "","list", "category"
				# raise self.pretty_inspect
				if @input.nil?
				return List.new(
						:creator_id => @current_user.id,
						:tag_id  => @list.tag_id ? @list.tag_id : nil,
						:label => nil
						) 
				else
				return List.find_or_create(
						:creator_id => 	@current_user.id,
						:label => Gum.purify(@input),
						:tag_id =>  @list.tag_id ? @list.tag_id : nil
						# :tag_id => subject_is_user?(params[:subject]) ? nil :params[:subject].id
				)
				end
			when "tag", "tags"
				@input.split(",").each do |input|
					add_tag(:subject => @list.tag, :input => input)
				end
				
			else
				if params[:item]
					tag = Tag.find(params[:item])
				else
					tag = Tag.find_or_create(
						:label => Gum.purify(@input), 
						:kind => @argument
					)
				end
		
				subj_id = @list.tag_id ? @list.tag_id : current_user.tag_id
				@argument.split("#").each do |kind|
	
					@t = Tagging.find_or_create( 
											:owner => @current_user, 
											:subject_id =>  subj_id, 
										 	:object_id => tag.id, 
											:kind => kind
										)
						if subj_id != @current_user.tag_id			
							Tagging.find_or_create( 
												:owner => @current_user, 
												:subject_id =>  tag.id, 
											 	:object_id => subj_id, 
												:kind => @list.tag.kind
											)
						end
				end
				
				return @t
			
			end
	end
	
	def add_description(source)
		source.description = @input
		source.save
		
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
		items = params[:content].items(:page => 1, :per_page => 10, :perspective => params[:service])
		
		@current_user.email_to(:user => user, :content => params[:content], :message => params[:message], :items => items)
	end
	
	def invite_user(params)
		user = User.find(:first, :conditions => ["email = ?",params[:email]])
		if user.nil?
			user = User.new(:email => params[:email], :login => params[:email], :password => "welcome")
			user.save
		end
		items = params[:content].items(:page => 1, :per_page => 10, :perspective => params[:service])
		@current_user.invite(:user => user, :to => params[:content], :items => items, :message => params[:message])
	end
	
	def add_image_to(source)
		# raise self.pretty_inspect
		uploaded_data = @image_url[:uploaded_data] rescue nil
		source.add_image(:uploaded_data => uploaded_data, :source_url => @input)
		source.images.last
	end
	
	def add_tag(params)
		tag = Tag.find_or_create(
			:label => Gum.purify(params[:input]), 
			:kind => "tag"
		)

		Tagging.find_or_create(
			:owner => @current_user,
			:subject_id => tag.id,
			:object_id => params[:subject].id,
			:kind => params[:input],
			:description => "#{params[:subject].label} #{tag.label}"
		)	
	end
	
	def search_results(params = {})
		params[:page] ||= 1
		case @service
		when "google"
			return Googleizer::Request.new(@input, :mode => @argument || "web").response.results
		when "amazon"
			return Finder::Search.find(:query => @input, :service => 'amazon')
		else
			if @argument
				
				return @list.items(:label => @input, :page => params[:page], :per_page => params[:per_page], :perspective => "everyone")
			else
				return @current_user.connections(:label => @input, :page => params[:page], :per_page => params[:per_page], :kind => @argument.split('#').last)
			end
		end
	end
	
	def localize(source, request)
		if source.is_a?(Tagging) && source.subject.has_address?
			sll = source.subject.coordinates.join(',')
			query = "#{source.label} #{source.kind}"
		else
			
			sll = Graticule.service(:host_ip).new.locate(request.remote_ip).coordinates.join(',') rescue "40.746497,-74.009447"	
			query = source

		end
		Googleizer::Request.new(query, :mode => "local").response(:sll => sll, :rsz => "small").results
	end

end
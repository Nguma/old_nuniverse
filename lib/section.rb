class Section
	attr_reader :path, :perspective, :no_wrap
	
	def initialize(params = {})
		@path = TaggingPath.new params[:path]
		@order = params[:order] || nil
		@kind = params[:kind] || nil
		@perspective = params[:perspective] || nil
		@degree = params[:degree] || nil
		@page = params[:page] || 1
		@no_wrap = params[:no_wrap] || nil
	end
	
	def subject
		@path.last_tag
	end
	
	def connections(params = {})
		if @perspective == "you"
			path = @path
			user = params[:user]
		else
			user = nil
			path = public_path
		end
		Tagging.with_object_kinds(@kind).with_user(user).with_path(path,@degree).include_object.groupped.with_order(@order).paginate(
				:page => @page, 
				:per_page => 20
		)
	end
	
	def public_path
		TaggingPath.new [@path.last_tag]
	end
	
	def is_web_service?
		return false if @perspective.nil?
		return false if ['you','everyone','private','public'].include?(@perspective)
		return true
	end
end
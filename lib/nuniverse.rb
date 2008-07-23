class Nuniverse
	attr_reader :path
	
	def initialize(params = {})
		@path = TaggingPath.new params[:path]
		@user = params[:user] || nil
  end

	def tag
		@path.last_tag
	end
	
	def empty?
		Tagging.with_path(@path, "all").empty?
	end

	def overview(params = {})
		Tagging.with_path(@path, "all").with_user(@user).include_object.by_latest.paginate(
		:page => params[:page] || 1,
		:per_page => 20)
	end

end
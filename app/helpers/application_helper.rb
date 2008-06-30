# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def head_for(view)
		return render(:partial => "/#{view}/head") rescue nil
	end
	
	
	def avatar_for(tag)
		return "" if tag.avatar.nil?
		return link_to(image_tag(tag.avatar.public_filename(:small), :alt => tag.content, :style =>"width:20px"), tag, :class => 'avatar')
	end
	
	def path_for(connection)
		@path = connection.path.split('_')
		@tags = Tag.find(:all, :conditions => ['id in (?)', @path])
		return @tags.collect {|t| t.content+'>'}
	end
	
	def nuniverse_of(tag, options = {}, &block)
		content = capture(&block)
    concat(
      render(
        :partial => '/tags/nuniverse',
        :locals => {:tag => tag, :content => content}
      ), block.binding
    )
	end
end

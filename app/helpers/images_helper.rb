module ImagesHelper
	
	# image for the corresponding source
	def avatar_for(source)
		source = source.is_a?(Tagging) ? source.object : source
		
		return nil if source.avatar.blank?
		return image_tag(source.avatar, :alt => source.avatar, :class => "avatar") rescue nil
	end

	# thumbail image for the corresponding source
	def thumbnail_tag(source, params = {})
		# source = source.is_a?(Connection) ? source.subject : source
		# params[:kind] ||= source.kinds
		params[:mode] ||= @mode
		params[:class] ||= "thumbnail"
		
		image_tag = source.kind == "image" ? source : source.subjects.with_kind('image').first
		
		if image_tag.nil? 
			if !source.property("thumbnail").blank? 
				return image_tag(source.property("thumbnail"), :alt => "", :class => params[:class] )
			else
				return image_tag("/images/icons/#{source.kind}.png", :alt => "", :class => params[:class] << " default_img", :style => "width:50px;height:50px")
			end
		else
			return image_tag(params[:mode] == "image" ? image_tag.source.public_filename : image_tag.source.public_filename(:small), :alt => "", :class => params[:class] )
		end


	
	end
	
	
	def images_for(collection, params = {})
		params[:source] ||= nil
		collection.collect {|c| 
			render :partial => "/images/box", :locals => {:item => c, :source => params[:source]}
		 }
	end
	
end

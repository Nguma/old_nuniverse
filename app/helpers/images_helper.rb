module ImagesHelper
	
	# image for the corresponding source
	def avatar_for(source)
		source = source.is_a?(Tagging) ? source.object : source
		
		return nil if source.avatar.blank?
		return image_tag(source.avatar, :alt => source.avatar, :class => "avatar") rescue nil
	end

	# thumbail image for the corresponding source
	def thumbnail_tag(source, params = {})
		source = source.is_a?(Connection) ? source.subject : source
		
		params[:kind] ||= source.kind
		
		image_tag = source.kind == "image" ? source : source.subjects.with_kind('image').first
		
		if image_tag.nil? 
			if !source.property("thumbnail").blank? 
				img = source.property("thumbnail")
			else
				img = "/images/icons/#{source.tags.first.gsub(' ', '_')}.png" rescue "/images/icons/#{source.kind}.png"
			end
		
		else
			raise image_tag.inspect if image_tag.source.nil?
			img = @mode == "image" ? image_tag.source.public_filename : image_tag.source.public_filename(:small)
		end
		

		return image_tag(img, :alt => "", :class => params[:class] || "thumbnail")
	
	end
	
	
	def images_for(collection, params = {})
		params[:source] ||= nil
		collection.collect {|c| 
			render :partial => "/images/box", :locals => {:item => c, :source => params[:source]}
		 }
	end
	
end

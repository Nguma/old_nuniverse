module ImagesHelper
	
	# image for the corresponding source
	def avatar_for(source)
		source = source.is_a?(Tagging) ? source.object : source
		
		return nil if source.avatar.blank?
		return image_tag(source.avatar, :alt => source.avatar, :class => "avatar") rescue nil
	end

	# thumbail image for the corresponding source
	def thumbnail_tag(source, params = {})
		params[:class] ||= "thumbnail"
		params[:size] ||= "small"
		params[:title] ||= source.name
	
		# image_tag(source.avatar.public_filename(params[:size]), params) rescue  image_tag("/images/icons/#{source.class.to_s.downcase}.png",  params.merge({:class => "default"}))	
		image_tag(source.avatar.public_filename(params[:size]), params) rescue nil	
	end
	
	
	def images_for(collection, params = {})
		params[:source] ||= nil
		collection.collect {|c| 
			render :partial => "/images/box", :locals => {:item => c, :source => params[:source]}
		 }
	end
	
	
	def face_for_ranking(ranking, params = {})

		if ranking.score < 1
			image = ranking.user.bad_face(:size => params[:size]) 
		elsif ranking.score > 1
			image = ranking.user.good_face(:size => params[:size]) 
		else
			image = ranking.user.poker_face(:size => params[:size])
		end
		image = ranking.user.poker_face(:size => params[:size]) if image.nil?
		image_tag(image, :class => "thumbnail") rescue nil 
	end
	
end

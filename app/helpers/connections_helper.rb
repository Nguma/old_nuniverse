module ConnectionsHelper
	def render_preview(connection)
		tag = connection.is_a?(Connection) ? connection.subject : connection
		case connection.kind
		when "address"
			render :partial => "/previews/address", :locals => {:connection => connection}
		when "image"
			render :partial => "/previews/image", :locals => {:tag => tag}
		when "video"
			render :partial => "/previews/video", :locals => {:tag => tag}
		when "bookmark"
			render :partial => "/previews/bookmark", :locals => {:tag => tag}
		when "comment","tweet"
			render :partial => "/previews/comment", :locals => {:tag => tag}
		when "product"
			render :partial => "/previews/product", :locals => {:tag => tag}
		else
			render :partial => "/previews/nuniverse", :locals => {:connection => connection}
		end
	end
end

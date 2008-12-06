module ConnectionsHelper
	def render_preview(connection)
		case connection.subject.kind
		when "image"
			render :partial => "/previews/image"
		when "video"
			render :partial => "/previews/video"
		when "bookmark"
			render :partial => "/previews/bookmark"
		else
			render :partial => "/previews/nuniverse"
		end
	end
end

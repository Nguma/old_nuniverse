module ConnectionsHelper
	def link_to_connection(connection)
		polymorphic_url(connection.subject) rescue  nil
		url = connection.pending? ?  connection : polymorphic_url(connection.subject, :klass => "Nuniverse")
		if connection.subject.is_a?(Bookmark)
			link_to(connection.subject.name.capitalize, connection.subject.url, :class => "title", :target => "_blank")
		else
			link_to(connection.subject.name.capitalize, url, :class => "title")	
		end
	end
	
	def render_connection_description(connection)
		link = link_to_connection(connection)
		d = connection.description.blank? ? connection.twin.description : connection.description rescue nil
		return link if d.blank?
		reg = Regexp.escape(connection.subject.name)
		if d.match(/#{reg}\b/i)
			return d.gsub(/#{reg}\b/i, link)
		else
			return  "#{link}. #{d.gsub(/connection.subject.name/,link)}"
		end

		
	end
	
	def authorized_to_edit?(connection)
		return true if connection.object == current_user
		return true if !connection.subject.is_a?(User) && !connection.object.is_a?(User)
		return false
	end
	
	
	def connect_link(params)
		link_to params[:title], make_connection_url(:subject_id => params[:subject].id, :subject_type => params[:subject].type, :object_id => params[:object].id, :object_type => params[:object].type)
	end
	
	
end

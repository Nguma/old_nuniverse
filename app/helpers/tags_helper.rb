module TagsHelper

	def link_to_visit(tag, params ={})
		
		if tag.url.nil?
			link_to tag.label.capitalize, visit_url(tag.id, @perspective.tag.label), params
		else
			params[:target] = "_blank"
			link_to tag.label.capitalize, tag.url, params
		end
	end
	
	def tag_content
		params[:kind] ||= @kind
		if service_is_nuniverse?
			lists_for(@tag)
		else
			results = []		
			service_items.each_with_index do |result,i|
				results << "#{render :partial => "/taggings/#{@service}", :locals => {:result => result, :tag => @tag}}"
			end
			results
		end
	end
	
	
	def service_items(params = {})
		params[:service] ||= @service
		params[:source] ||= @source
		query = "+#{params[:source].label}  #{tag_info(params[:source])}"

		case params[:service]
		when "google"	
			Googleizer::Request.new(query , :mode => "web").response.results
		when "amazon"
			query = "#{@source.label}"
			Finder::Search.find(:query => query, :kind => @kind,:service => 'amazon')
		when "youtube"
			Googleizer::Request.new(query , :mode => "video").response.results
		when "yelp"
			Finder::Yelp.new(:tag => params[:source]).results
		else
			raise "'#{params[:service]}' is not a valid service name."
		end
	end
	
	def tag_info(tag, params = {})
		params[:tag]  = tag
		params[:perspective] ||= @perspective
		params[:kind] ||= (@kind.nil? ? tag.kind : @kind)
		params[:page] = @page || 1
		info =  Nuniverse.collect_infos(params)
		
		
	end
	
	def tag_links(tag, params = {})
		params[:kind] ||= @kind
		case params[:kind].singularize
		when 'film'
			[link_to("Rent it on Netflix","#"),link_to("Buy it on Amazon",tag_url(tag, :service => 'amazon', :kind => params[:kind]))]
		when 'location'
			[]
		when 'restaurant','bar','club'
			[link_to("Reviews from yelp","#")]
		when 'bookmark'
			[]
		when 'album'
			[]
		else
			[]
		end
	end
	
	def select_tags(params)
			params[:users] ||= [0]
			sql = "SELECT DISTINCT T.* FROM tags T LEFT OUTER JOIN taggings TA on TA.object_id = T.id LEFT OUTER JOIN tags S on TA.subject_id = S.id"
			sql << " WHERE (TA.user_id = '#{current_user.id}' "
			case params[:service]
			when "you"
				
			when "everyone"
				sql << " OR (TA.user_id in (#{params[:users]}) AND  public = 1 ) "
			else
				sql << " OR public = 1 "
			end
			sql << " ) AND '#{params[:query]}' rlike CONCAT('(',S.label,'|',S.kind,')?.*(',TA.kind,'|',T.kind,')' )"
			sql << " GROUP BY T.id"
			sql << " ORDER BY #{params[:order] || "T.label ASC"} "

			Tag.paginate_by_sql(sql, :page => params[:page] || 1, :per_page => params[:per_page] || 3)
	end
	
	def add_to_fav_link(item, params = {}) 
		personal = item.personal.to_i  rescue 0

		if personal == 1
				link_to(image_tag("/images/icons/heartbreak.png"),
					remove_from_nuniverse_url(
						:nuniverse => params[:source].id,
						:item => item.object.id
					),:class => "add_to_fav_lnk hidden", :title => "Remove from your connections")
		else
			link_to(image_tag("/images/icons/save.png"),
				add_to_nuniverse_url(
					:nuniverse => params[:source].id, 
					:kind => item.kind, 
					:tag => item.object.id, 
					:input => item.object.label, 
					:url => item.object.url, 
					:kind => item.object.kind, 
					:data => item.object.data, 
					:description => item.object.description, 
					:service => item.object.service 
				), :class => "add_to_fav_lnk hidden", :title => "Save")
		
		end
	end
end
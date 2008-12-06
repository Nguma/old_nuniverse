class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	def index
	end
	
	def users
		@users = User.find(:all).paginate(:page => params[:page] || 1, :per_page => 20)
	end
	
	def send_activation_code
		@user = User.find(params[:id])
		UserMailer.deliver_activation_code(@user)
		redirect_to "/admin/users"
	end
	
	def permissions
		@page = params[:page] || 1
		@permissions = Permission.find(:all).paginate(:page => @page, :per_page => 10)	
	end
	
	def scrap
		@origin = Tag.find(params[:id])
		@url = params[:url]
		doc = Hpricot open @url
		@list = (doc/:table/:tr)
		@list.each do |row|
			col_length = (row/:td).length
			if col_length == 2
			
				img = (row/:td/:img)
				title = (row/:td/:b/:i).innerHTML.gsub(/\.$/,'')
				description = (row/:td)[1].innerHTML
				t = Tag.new(:label => title, :kind => "painting", :description => description)
				image_url = [@url.gsub(/http\:\/\/www.abcgallery.com\/(\w)\/(\w+)\/.*/,'http://www.join2day.net/abc/\1/\2/'), img[0].attributes['src'].gsub(/s(.*)\.jpg/,'\1.JPG') ].join('')
				t.save
				t.add_image(:source_url => image_url) rescue nil
				t.tag_with(['painting'],:context => @origin.id)
				@origin.tag_with(['painter'],:context => t.id)
				
			end
				
		end
	end
	
	def ct 

		cts = []
cts.each_with_index do |ct,i|
			
				
				t = Tag.new(:label => ct[0], :kind => 'character', :data => "#wikipedia_url #{ct[1]} ")
				
				# unless ct[1].blank?
				# 					wiki_content = Nuniverse.get_content_from_wikipedia(ct[1])
				# 						
				# 						t.description = Nuniverse.wikipedia_description(wiki_content).to_s
				# 						t.save
				# 						img = (wiki_content/'table.infobox'/:img).first
				# 						unless img.nil? || img.to_s.match(/Replace_this_image|Flag_of/)
				# 							t.add_image(:source_url => img.attributes['src'])
				# 						end
				# 				else
				# 					t.save
				# 				end
				t.save
				t.tag_with(['comic character','supervillain'],:context => 6239);
		
				# if !ct[1].blank?
				# 				
				# 					t.add_image(:source_url => "http://en.wikipedia.com#{ct[1]}")
				# 				end
				# t = "/wiki/#{ct.label.titleize.gsub(' ','_')}"
				# 			
				# 			
				# 			begin
				# 				begin
				# 					w = Nuniverse.get_description_from_wikipedia("#{t}_(Film)")
				# 					raise false if (w/'#noarticletext')
				# 				rescue
				# 					w = Nuniverse.get_description_from_wikipedia("#{t}_(film)")
				# 					raise false if (w/'#noarticletext')
				# 				end
				# 			rescue
				# 				w = Nuniverse.get_description_from_wikipedia("#{t}")
				# 			end
				# 			
				# 			if w
				# 				img = (w/'table.infobox'/:img).first
				# 				unless img.nil? || img.to_s.match(/Replace_this_image|Flag_of/)
				# 					ct.add_image(:source_url => img.attributes['src'].gsub('thumb/',''))
				# 				end
				# 			end
		# end
		# dc = Hpricot(ct.description)
		# 
		# 	ct.description = dc.to_s
		# ct.save
	end
	end
	
	def batch
		@kinds = ["company"]
		tags  = Tag.find(:all, :conditions => ["kind in (?)", @kinds])
		
		tags.each do |tag| 
			# @c = Connection.create(
			# 			:subject => tag,
			# 			:object => tag,
			# 			:public => 1
			# 		)
			
				Tagging.create(
					:taggable => tag,
					:predicate => tag.kind
					)
		end
		
		render :nothing => true
		
	end
	
	def test
		current_user.connections
	end
	
	def netflix
		t = Finder::Netflix.new
		
		if session[:request_token].nil?
			@request_token = t.request_token
			session[:request_token] =  @request_token.token
			session[:request_token_secret] =  @request_token.secret
			redirect_to t.authorization_url
		else
			
			@request_token = OAuth::RequestToken.new(t.consumer,session[:request_token],session[:request_token_secret])
			
			@access_token = @request_token.get_access_token 
			raise @access_token.inspect
			session[:request_token] = nil
			session[:request_token_secret]
		end
		
	end
	
	def groups
		@groups = Group.find(:all)
	end
	
	protected
	
end

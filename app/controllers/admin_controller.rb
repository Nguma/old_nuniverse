class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	before_filter :find_source, :only => :save_layout
	
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
	
	
	def scrap_wikipedia
		@fruits = Nuniverse.find(:all, :conditions => {:id => 7..54})
		@fruit = Nuniverse.find(2543)
		@fruit.nuniverses << @fruits
	end
	
	def scrap_dbpedia 
		@museum = Nuniverse.find_by_unique_name("museum")
		@manhattan = Nuniverse.find_by_unique_name("manhattan")
		
		@rsts.each do |rst|
			name = rst[0].gsub('_',' ')
			n = Nuniverse.create(:unique_name => "#{rst[0].gsub('_','-')}", :name => name) 
			n.images << Image.create(:source_url => rst[2]) rescue nil
			n.locations << Location.create(:name => name, :latlng => rst[1])
			@museum.nuniverses << n
			n.nuniverses << @manhattan
			@manhattan.nuniverses << n
		end
		
	end
	
	def scrap_ikea
		@ikea = Nuniverse.find(6262)
		@url = "http://www.ikea.com/us/en/catalog/productsaz/"
		
		23.times do |time|
			t = time+2
		doc = Hpricot open "#{@url}#{t}"
	
		
		(doc/:span/:a).each do |lnk|
			
			ikea = lnk.attributes['href'].scan(/(\/products\/(\w+))/)[0]
			unless ikea.nil? || ikea[1].nil?
				n = Nuniverse.find_by_unique_name("ikea-#{ikea[1]}")
				if n.nil?

					lnkdoc = Hpricot open "http://www.ikea.com#{lnk.attributes['href']}"
					
					
					n = Nuniverse.create(:active =>1 ,:unique_name => "ikea-#{ikea[1]}", :name => lnkdoc.at("#productName").inner_html.titleize, :description => lnkdoc.at("#productType").inner_html )
					n.bookmarks << Bookmark.create(:name => "#{n.name} at Ikea", :url => ikea[0])
					n.images << Image.create(:source_url => "http://www.ikea.com/#{lnkdoc.at("#productImg").attributes['src']}")
					n.tags << Tag.find_or_create(:name => n.description)
					
				end
				@ikea.nuniverses << n if n
				
			end
		end
	end
		
	end
	
	def ct 
		tag = Tag.find(:first, :conditions => {:name => "painting"})
		date_tag = Tag.find(:first, :conditions => {:name => "date"})
		gaugin = Nuniverse.find(2510)
		
		cts = [	]		
			cts.each do |ct|
				painting = Nuniverse.search(ct[0], :conditions => {:tag_ids => tag.id}).first
					begin 
						painting.tags << tag 
					rescue 
						
					end
					
					begin 	painting.nuniverses << gaugin  rescue nil end
					begin gaugin.nuniverses << painting rescue nil end
	
					unless ct[1].blank?
				#	begin	painting.images << Image.create(:source_url => "http://en.wikipedia.org#{ct[1]}") rescue nil end
					end
					unless ct[2].blank?
						date = Nuniverse.search(ct[2], :conditions => {:tag_ids => date_tag.id}) rescue Nuniverse.create(:name => ct[2], :active => 1)
						begin painting.nuniverses << date rescue nil end
						begin date.nuniverses << painting rescue nil end
					end
				painting.save
			end
	

	end
	
	def batch
	
	end
	
	def test
	
	
	end
	
	def test_2
		@source = Story.find(48)
		@connections = @source.connections.of_klass('Nuniverse')
	end
	
	def save_data
		@source = Story.find(49)
			@position = Tag.find_or_create(:name => "Room")
			# @member = Tag.find_or_create(:name => "member")
			# @goal =  Tag.find_or_create(:name => "goals")
			ns = []
	
			params['item'].to_a.each do |item|
				
				item = item[1]
				unless item['name'].blank?
				n = Nuniverse.find_or_create(item['name'])
				p = Polyco.create(:subject => n, :object => @source) rescue nil
				# p.tags << @member rescue nil
				pos = Fact.new(:body => item['position'])
				pos.tags << @position rescue nil
				# goals = Fact.new(:body => item['goals'])
				# goals.tags << @goal
				n.facts << [pos] rescue nil
				ns << n rescue nil
				@source.nuniverses << ns rescue nil
			end
			end
			
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

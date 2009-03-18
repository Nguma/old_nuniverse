class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	before_filter :find_source, :only => :save_layout
	
	def index
	end
	
	def users
		@users = User.find(:all).paginate(:page => params[:page] || 1, :per_page => 20)
	end
	
	def groups
		@groups = Group.find(:all)
	end
	
	def send_activation_code
		@user = User.find(params[:id])
		UserMailer.deliver_activation_code(@user)
		redirect_to "/admin/users"
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
	
	def batch
		rev_tag = Tag.find_by_name('review')
		like = Tag.find_by_name('comment')
		@pos = Polyco.find(:all)

		@pos.each do |p|
			p.
		end
	end
		

	

	protected
	
	
	def boxing
			if FileTest.exist?("#{LAYOUT_DIR}/#{@source.class.to_s}_#{@source.id}.xml")
				@layout =	XMLObject.new(File.open("#{LAYOUT_DIR}/#{@source.class.to_s}_#{@source.id}.xml")).boxes rescue []
			else
				@layout  = XMLObject.new(File.open("#{LAYOUT_DIR}/Template_#{@source.class.to_s}.xml")).boxes
			end
		end
	
end

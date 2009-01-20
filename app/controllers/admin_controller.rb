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
		
		cts = [
		["Mandolina and Flowers","","1883"],
		["Bouquet","","1884"],["Cattle Drinking","","1885"],["Still Life with Mandolin","","1885"],
		["Study for the Bathers","","1886"],["The Four Breton Girls","","1886"],["Breton Shepherdess","","1886"],
		["Washerwomen at Pont-Aven","","1886"],["At the Pond","","1887"],["Huts under Trees","","1887"],
		["Palm Trees on Martinique","","1887"],["Head of a Negress","","1887"],["Madame Alexandre Kohler","","c.1887-88"],
		["Still Life with Three Puppies","","1888"],["Breton Girls Dancing, Pont-Aven","","1888"],
		["Breton Girls Dancing","","1888"],["Madeleine Bernard","","1888"],
		["Vision after the Sermon; Jacob Wrestling with the Angel","","1888"],["Night Cafe at Arles","","1888"],
		["Van Gogh Painting Sunflowers","","1888"],["Women from Arles in the Public Garden, the Mistral","","1888"],
		["Hay-Making in Brittany","","1888"],["Bouquet of Flowers with a Window Open to the Sea (Reverse of Hay-Making in Brittany)","","1888"],["The Alyscamps","","1888"],["Harvesting of Grapes at Arles (Mis√®res humaines)","","1888"],["Fruits","","1888"],["Ceramic Vase with a Caricature Self-Portrait","","1889"],["Bonjour, Monsieur Gauguin","","1889"],["Still Life with Fan","","1889"],["The Schuffenecker Family","","1889"],["The Yellow Christ","/wiki/The_Yellow_Christ","","1889"],["Christ on the Mount of Olives","","1889"],
		["Caricature Self-Portrait","","1889"],["Self-Portrait with Yellow Christ","","1889"],["Ondine","","1889"],["Yellow Hay Ricks","","1889"],["Nirvana, Portrait of Meyer de Haan","","1889"],["La Belle Ang√®le (Portrait of Madame Satre)","","1889"],["Be in Love and You Will Be Happy","","1889"],["Eve. Don't Listen to the Liar","","1889"],["Study for La perte de Pucelage","","1890"],["Mimi and Her Cat","","1890"],["Portrait of a Woman with Cezanne Still-Life","","1890"],["Haystacks in Brittany","","1890"],["Landscape","","1890"],["Ia Orana Maria","/wiki/Image:Paul_Gauguin_071.jpg","1891"],["Vahine no te tiare (Woman with a Flower)","","1891"],["Te Faaturuma (Brooding Woman)","","1891"],["Les Parau Parau (Conversation)","","1891"],["I Raro te Oviri (Under the Pandanus)","","1891"],["The Meal (The Bananas)","","1891"],["Tahitian Women on the Beach","/wiki/Tahitian_Women_on_the_Beach","1891"],["The Fisherwomen of Tahiti","","1891"],["Black Pigs","","1891"],["Self-Portrait","","1891"],["Self-portrait","","1891"],["Head of a Woman","","c.1891-92"],["Va√Øraumati tei oa (Her Name is Vairaumati)","","1892"],["Manao tupapau (The Spirit of the Dead Keeps Watch)","/wiki/Image:Paul_Gauguin_025.jpg","","1892"],["Aha oe feii? (Are You Jealous?)","","1892"],["Fatata te miti (Near the Sea)","","1892"],["Musique barbare","","c.1891-93"],["Parau Api (What's New?)","","1892"],["Vahine no te vi (Woman with a Mango)","","1892"],["Ta Matete","/wiki/Image:Ta_matete.jpg","1892"],["Piti Teina. (Two Sisters)","","1892"],["Taperaa Mahana","","1892"],["Joyeusete (Arearea)","","1892"],["Tahitian Eve","","c.1892"],["Words of the Devil","","c.1892"],["Nafea Faa ipoipo? (When Will You Marry?)","","1892"],["Study for \"When Will You Marry?\"","","c.1892"],["Fatata te mou√† (At the Foot of a Mountain)","","1892"],["Self-Portrait","","c.1890s"],["Matamoe (Landscape with Peacocks)","","1892"],["Arii Matamoe (The Royal End)","","1892"],["Parau na te varua ino (Words of the devil)","","1892"],["Merahi metua no Tehamana (Ancestors of Tehamana)","","1893"],["Aita Tamari vahina Judith te Parari (Annah the Javanese)","","1893"],["Te Tiare Farani (Bouquet of Flowers)","","1893"],["Pastorales Tahitiennes","","1893"],["E√º haere ia oe (Woman Holding a Fruit)","","1893"],["Tahitian Landscape","","1893"],["The Messengers of Oro. Illustration for 'L'Ancien culte mahorie', leaf 24","","1893"],["Pape Moe (Mysterious Water)","","1893"],["Self-Portrait","","c.1893-94"],["Portrait of William Molard. Reverse of Self-Portrait","","c.1893-94"],["Floral and Vegetal Motifs","","1893"],["Tahitian Woman in a Landscape","","1893"],["Breton Landscape (The \"Moulin David\")","","1894"],
		["Breton Village in Snow","","1894"],["Portrait of Mother","","1894"],["Siesta","","1894"],["Two Breton Women on the Road","","1894"],["Head of Young Breton Peasant Woman","","c.1894"],["The Cellist (Portrait of Upaupa Scheklud)","","1894"],["Mahana no atua (Day of God)","","1894"],["Nave Nave Moe (Sacred Spring)","","1894"],["Ceramic vase with Tahitian Gods - Hina and Tefatou","","c.1894-95"],["Vairumati","","1896"],["Te arii vahine (The King's Wife)","","1896"],["Self-Portrait","","1896"],["No te aha oe riri? (Why Are You Angry?","","1896"],["Eiaha Ohipa (Not Working)","","1896"],["Still Life with Mangoes","","1896"],["Scenes from Tahitian Life","","1896"],["Bouquet of Flowers","","1896"],["Te Arii Vahine (Queen)","","1896"],["Self-Portrait","","1896"],["Te Vaa (The Canoe)","","1896"],["Te Tamari No Atua (Nativity)","","1896"],["Baby (The Nativity)","","1896"],["Tarari maruru (Landscape with Two Goats)","","1897"],["Man Picking Fruit from a Tree","","1897"],["Nevermore, O Taiti","","1897"],["Where Do We Come From? What Are We? Where Are We Going?", "/wiki/Where_Do_We_Come_From%3F_What_Are_We%3F_Where_Are_We_Going%3F", "1897"],["The White Horse","","1898"],["Rave te hiti aamy (The Idol)","","1898"],["Te Pape Nave Nave (Delectable Waters)","","1898"],
		["The Bathers","/wiki/The_Bathers","1898"],["Horse on Road. Tahitian Landscape","","1899"],["Motherhood (Women on the Shore)","","1899"],["Te avae no Maria (Month of Maria)","","1899"],["Three Tahitian Women Against a Yellow Background","","1899"],["The Great Buddha","","1899"],
		["Two Tahitian Women with Mango Blossoms","","1899"],["Three Tahitians","","1899"],["Tahitian Woman","","c.1900"],["Ford (Running Away)","","1901"],["Sunflowers","","1901"],["Tahitian Idyll","","1901"],["And the Gold of Their Bodies (Et l'or de leurs corps)","","1901"],["The Call","","1902"],["Girl with a Fan","","1902"],["Horsemen on the Beach","","1902"],["Barbarous Tales","","1902"],["Adam and Eve","","1902"],["The Sorcerer of Hiva Oa","","1902"],["Still Life with Parrots","","1902"],["Mother and Daughter","","1902"],["Haere Mai","","1902"],["In the Vanilla Grove, Man and Horse","","1902"]
		]		
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
		raise Nuniversal.localize("335 w 20th street Nyc ny 10011", current_user).inspect
		ps = Polyco.find(:all, :conditions => ["description is not null AND object_type = 'Nuniverse'"])
		ps.each do |p|
		end
	end
	
	def test
		# raise Nuniversal.tokenize("It is the last day of #damson").inspect 
		@poll = Comment.new(:author => current_user)
		
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

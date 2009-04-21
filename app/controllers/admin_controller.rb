class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	before_filter :find_source, :only => :save_layout
	
	def twitter
		@client = TwitterSearch::Client.new 'wdyto'
		@tweets = @client.query '#nyc'
		raise @tweets.inspect
		
		
		# TwitterOauth::Client.new(:consumer_key 'mDpj6JFZdEi1jead8mmC3g', :consumer_secret => 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
			# Twitter::Client.new(:login => "nuniverse", :password => "abc123").timeline_for(:me, :since => 5.month.ago).each do |status|
			# 			@user = User.find_by_login(status.user.screen_name)
			# 			scan = status.text.scan(/^\#(\w+)\s*\+(\d)/i)[0]
			# 		
			# 			@nuniverse = Nuniverse.find_by_unique_name(scan[0].to_s)
			# 			@vote = scan[1]
			# 			raise "#{@user.firstname} voted +#{@vote} for #{@nuniverse.name}"
			# 		end
	end
	
	def oauth
		
	    oauth = Twitter::OAuth.new('mDpj6JFZdEi1jead8mmC3g', 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
	    session['rtoken'] = oauth.request_token.token
	    session['rsecret'] = oauth.request_token.secret
	    redirect_to oauth.request_token.authorize_url
			return
 	end

	def oauthacc
		oauth = Twitter::OAuth.new('mDpj6JFZdEi1jead8mmC3g', 'RLpbiKGRbFLEVCCGmekFujCrEKPyRjN2x6kF4hPZnA')
		raise oauth.get
	end

	
	
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
		
		@api_key = "srnpu8b448ca2fj5q6vkrppd"
		@shared_secret = "nuMWRS9hRQ"
		require "netflix"
		@c = Netflix::AssHat.new(@api_key, @shared_secret, "nuniverse")
		raise @c.acquire_request_token("http://www.nuniverse.net").inspect
		
		# t = Finder::Netflix.new
		# 	
		# 	if session[:request_token].nil?
		# 		@request_token = t.request_token
		# 		session[:request_token] =  @request_token.token
		# 		session[:request_token_secret] =  @request_token.secret
		# 		redirect_to t.authorization_url
		# 	else
		# 		@request_token = OAuth::RequestToken.new(t.consumer,session[:request_token],session[:request_token_secret])
		# 		
		# 		@access_token = @request_token.get_access_token 
		# 		session[:request_token] = nil
		# 		session[:request_token_secret]
		# 	end
		# 	
	end
	
	def batch
		tag1 = Tag.find_or_create(:name => "video game")
		d_tag = Tag.find_or_create(:name => "video game developer")
		p_tag = Tag.find_or_create(:name => "video game publisher")
		tag4 = Tag.find_or_create(:name => "american")
		
		@ar = [["Cookie_Monster_Munch"],["Cool_Spot"],["The_Corporate_Machine"],["Corridor_7"],["Cosmic_Race_(video_game)"],["Cosmology_of_Kyoto"],["Counter-Strike"],["Counter-Strike:_Condition_Zero"],["Counter-Strike:_Source"],["Covert_Action"],["Crackdown"],["Crash_Bandicoot_series"],["Crash_Bandicoot_(video_game)"],["Crash_Bandicoot_2:_Cortex_Strikes_Back"],["Crash_Bandicoot_3:_Warped"],["Crash_Team_Racing"],["Crash_Bash"],["Crash_Bandicoot:_The_Wrath_of_Cortex"],["Crash_Bandicoot:_The_Huge_Adventure"],["Crash_Bandicoot_2:_N-Tranced"],["Crash_Nitro_Kart"],["Crash_Bandicoot_Purple:_Ripto%27s_Rampage"],["Crash_Twinsanity"],["Crash_Tag_Team_Racing"],["Crash_Boom_Bang!"],["Crash_of_the_Titans"],["Crash:_Mind_Over_Mutant"],["Crazy_Sue"],["Crazy_Sue_Goes_On"],["Crazy_Taxi_series"],["Cricket_2004"],["Cricket_2005"],["Crime_and_Punishment_(computer_game)"],["Crimson_Skies"],["Crimson_Skies:_High_Road_to_Revenge"],["Crisis_Zone"],["Critical_Mass_(video_game)"],["Crossfire_(computer_game)"],["Cruis%27n"],["Cruis%27n_(Wii)"],["Cruis%27n_Exotica"],["Cruis%27n_USA"],["Cruis%27n_Velocity"],["Cruis%27n_World"],["Cruise_Ship_Tycoon"],["Crusade_in_Europe"],["Crysis"],["Crystal_Castles"],["Crystal_Caves"],["Crystalis"],["Crystals_of_Zong"],["CSI:_Hard_Evidence"],["Culdcept"],["Curse_of_the_Azure_Bonds"],["Curses_(computer_game)"],["Custer%27s_Revenge"],["Cuthbert_Goes_Digging"],["Cuthbert_Goes_Walkabout"],["Cuthbert_in_the_Mines"],["Cyber-Lip"],["Cyberun"],["Cytron"],["Cytron_Masters"],["Cyvern"],["Dance_Dance_Revolution_(video_game)"],["Dance_Dance_Revolution_2ndMix"],["Dance_Dance_Revolution_3rdMix"],["Dance_Dance_Revolution_4thMix"],["Dance_Dance_Revolution_5thMix"],["Dance_Dance_Revolution_Best_Hits"],["Dance_Dance_Revolution_Disney_Channel_Edition"],["Dance_Dance_Revolution_Disney_Grooves"],["Dance_Dance_Revolution_Disney_Mix"],["Dance_Dance_Revolution_Disney%27s_World_Dancing_Museum"],["Dance_Dance_Revolution_Extra_Mix"],["Dance_Dance_Revolution_Extreme"],["Dance_Dance_Revolution_Extreme_2"],["Dance_Dance_Revolution_Full_Full_Party"],["Dance_Dance_Revolution_Hottest_Party"],["Dance_Dance_Revolution_Hottest_Party_2"],["Dance_Dance_Revolution_Kids"],["Dance_Dance_Revolution_Konamix"],["Dance_Dance_Revolution_Mario_Mix"],["Dance_Dance_Revolution_Party_Collection"],["Dance_Dance_Revolution_S"],["Dance_Dance_Revolution_Solo_2000"],["Dance_Dance_Revolution_Solo_Bass_Mix"],["Dance_Dance_Revolution_Strike"],["Dance_Dance_Revolution_SuperNova"],["Dance_Dance_Revolution_SuperNova_2"],["Dance_Dance_Revolution_Ultramix"],["Dance_Dance_Revolution_Ultramix_2"],["Dance_Dance_Revolution_Ultramix_3"],["Dance_Dance_Revolution_Ultramix_4"],["Dance_Dance_Revolution_Universe"],["Dance_Dance_Revolution_Universe_2"],["Dance_Dance_Revolution_Universe_3"],["Dance_Dance_Revolution_USA"],["Dance_Dance_Revolution_X"],["Dance_Dance_Revolution_Winx_Club"],["Dancing_Stage_EuroMix"],["Dancing_Stage_EuroMix_2"],["Dancing_Stage_Max"],["Dancing_Stage_MegaMix"],["Dancing_Stage_Fever"],["Dancing_Stage_Fusion"],["Dancing_Stage_Party_Edition"],["Dancing_Stage_SuperNova_2"],["Dancing_Stage_Universe"],["Dancing_Stage_Universe_2"],["Dancing_Stage_Unleashed"],["Dancing_Stage_Unleashed_2"],["Dancing_Stage_Unleashed_3"],["Dance_Praise"],["Daredevil_Dennis"],["Darius_(series)"],["Dark_Age_of_Camelot"],["Dark_Castle"],["Dark_Cloud"],["Dark_Chronicle"],["Dark_Colony"],["Darklands_(computer_game)"],["Dark_Reign"],["Dark_Reign_2"],["Darkstalkers"],["DarkSpace"],["Darkstone"],["Darwinia_(computer_game)"],["Dave_Mirra_Freestyle_BMX"],["Day_of_Defeat"],["Day_of_Defeat:_Source"],["Day_of_the_Tentacle"],["Dead_or_Alive_(video_game_series)"],["Dead_or_Alive_(1996_game)"],["Dead_or_Alive_2"],["Dead_or_Alive_Ultimate"],["Dead_or_Alive_3"],["Dead_or_Alive_4"],["Dead_or_Alive_Xtreme_Beach_Volleyball"],["Dead_or_Alive_Xtreme_2"],["Dead_or_Alive:_Code_Chronos"],["Dead_Rising"],["Deadly_Dozen"],["Deadline_(computer_game)"],["Deadly_Rooms_Of_Death"],["Death_Crimson_OX"],["Death_Rally"],["Deathlord"],["Deer_Avenger_(series)"],["Deer_Hunter"],["Defender_(arcade_game)"],["Defender_of_the_Crown"],["Delta_(computer_game)"],["Denki_Blocks!"],["Derby_Stallion_64"],["Descent_(computer_game)"],["Descent_2"],["Descent_3"],["Desperados:_Wanted_Dead_or_Alive"],["Destination_Adventure"],["Destroy_All_Humans!"],["Destroy_All_Humans!_2"],["Destroy_All_Humans!_Big_Willy_Unleashed"],["Destroy_All_Humans!_Path_of_the_Furon"],["Destruction_Derby"],["Deus_Ex"],["Deus_Ex:_Invisible_War"],["Devet"],
		["Devil_May_Cry"],["Devil_May_Cry_2"],["Devil_May_Cry_3:_Dante%27s_Awakening"],["Devil_May_Cry_4"],["Dexter%27s_Laboratory:_Chess_Challenge"],["D/Generation"],["Diablo_series"],["Diablo_(computer_game)"],["Diablo:_Hellfire"],["Diablo_II"],["Diablo_II:_Lord_of_Destruction"],["Diablo_III"],["Diamonds_(game)"],["Die_Hard:_Nakatomi_Plaza"],["The_Dig"],["Digger_(computer_game)"],["Dig_Dug"],["Dig_Dug_2"],["Dig_Dug_Deeper"],["Diggles,_the_Myth_of_Fenris"],["Digimon_Adventure:_Anode/Cathode_Tamer"],["Digimon_Adventure_02:_Tag_Tamers"],["Digimon_Battle_Spirit"],["Digimon_Battle_Spirit_2"],["Digimon_Digital_Card_Battle"],["Digimon_Racing"],["Digimon_RPG"],["Digimon_Rumble_Arena"],["Digimon_Rumble_Arena_2"],["Digimon_Tamers:_Battle_Spirit_Ver._1.5"],["Digital_Monster_Ver._S:_Digimon_Tamers"],["Digimon_World"],["Digimon_World_2"],["Digimon_World_3"],["Digimon_World_4"],["Digimon_World_Championship"],["Digimon_World_Data_Squad"],["Digimon_World_Dawn_and_Dusk"],["Digimon_World_DS"],["Dinohunters"],["Disaster_Report"],["Disciples:_Sacred_Lands"],["Disciples_II:_Dark_Prophecy"],["Disgaea:_Hour_of_Darkness"],["Disgaea_2:_Cursed_Memories"],["Disgaea_3:_Absence_of_Justice"],["Disney_Sing_It"],["Disruptor"],["Divine_Divinity"],["Divinity_2_%E2%80%93_Ego_Draconis"],["Dizzy_series"],["Dofus"],["Dogfights_The_Game"],["Dominions_II"],["Donald_Duck:_Goin%27_Quackers"],["Donald_Duck%27s_Playground"],["Donkey_Kong_(series)"],["Diddy_Kong_Racing"],
		["Donkey_Kong_(video_game)"],["Donkey_Kong_(Game_Boy)"],["Donkey_Kong"],["Donkey_Kong_3"],["Donkey_Kong_3"],["Donkey_Kong_64"],["Donkey_Kong_Classics"],["Donkey_Kong_Country"],["Donkey_Kong_Country_2:_Diddy%27s_Kong_Quest"],["Donkey_Kong_Country_3:_Dixie_Kong%27s_Double_Trouble!"],["Donkey_Kong_Jr."],["Donkey_Kong_Jr."],["Donkey_Kong_Jr._Math"],["Donkey_Kong_Jungle_Beat"],["Donkey_Kong_Land"],["Donkey_Kong_Land_2"],["Donkey_Kong_Land_3"],["Donkey_Konga"],["Donkey_Konga_2"],["DK-King_of_Swing"],["DK_Jungle_Climber"],["Don_King_Presents:_Prizefighter"],["Doom_series"],["Doom_(video_game)"],["Doom_II:_Hell_on_Earth"],["Final_Doom"],["Doom_64"],["Doom_3"],["Doom_3:_Resurrection_of_Evil"],["Doom_4"],["Doom_RPG"],["DoomRL"],["Doom:_The_Boardgame"],["Double_Dare_(video_game)"],["Double_Dragon"],["Dr._Mario_(video_game)"],["Dragon_Age:_Origins"],["Dragon_Ball:_Advanced_Adventure"],["Dragon_Ball_GT:_Final_Bout"],["Dragon_Ball_GT:_Transformation"],["Dragon_Ball_Online"],["Dragon_Ball_Z:_Budokai"],["Dragon_Ball_Z:_Budokai_2"],["Dragon_Ball_Z:_Budokai_3"],["Dragon_Ball_Z:_Burst_Limit"],["Dragon_Ball_Z:_Buu%27s_Fury"],["Dragon_Ball_Z:_Harukanaru_Densetsu"],["Dragon_Ball_Z:_Infinite_World"],["Dragon_Ball_Z:_Legendary_Super_Warriors"],["Dragon_Ball_Z:_Sagas"],["Dragon_Ball_Z:_Shin_Budokai"],["Dragon_Ball_Z:_Shin_Budokai_-_Another_Road"],["Dragon_Ball_Z:_Supersonic_Warriors"],["Dragon_Ball_Z:_Supersonic_Warriors_2"],["Dragon_Ball_Z:_The_Legacy_of_Goku"],["Dragon_Ball_Z:_The_Legacy_of_Goku_II"],["Dragon_Breed"],["Dragon_Quest"],["Dragon_Quest_(video_game)"],["Dragon_Quest_II"],["Dragon_Quest_III"],["Dragon_Quest_IV"],["Dragon_Quest_V"],["Dragon_Quest_VI"],["Dragon_Quest_VII"],["Dragon_Quest_VIII"],["Dragon%27s_Lair"],["DragonStrike_(computer_game)"],["Drakan:_Order_of_the_Flame"],["Drakan:_The_Ancients%27_Gates"],["Drake_of_the_99_Dragons"],["Drakengard"],["Drakkhen"],["The_Dreamhold"],["Driver_(series)"],["Driving_Emotion_Type-S"],["Druid_(computer_game)"],["Duck_Hunt"],["DuckTales"],["Duke_Nukem_3D"],["Dune_II"],["Zork"],["Dungeon_Crawl"],["Dungeon_Keeper"],["Dungeon_Master_(computer_game)"],["Dungeon_Master_II"],["Dungeon_Siege"],["Dungeons_of_Daggorath"],["Dynasty_Warriors"],["Dynasty_Warriors_2"],["Dynasty_Warriors_3"],["Dynasty_Warriors_3_Xtreme_Legends"],["Dynasty_Warriors_4"],["Dynasty_Warriors_4_Xtreme_Legends"],["Dynasty_Warriors_5"],["Dynasty_Warriors_Advance"],["Dynasty_Warriors_BB"],["Dynasty_Warriors_DS:_Fighter%27s_Battle"],["Dynasty_Warriors_Vol._2"],["EA_Sports"],["EA_Sports"],["Earl_Weaver_Baseball"],["Earth_2150"],["EarthBound"],["Earth_Defense_Force"],["Earthworm_Jim"],["Earth_No_More"],["Eastern_Front_(computer_game)"],["Eat_Lead:_The_Return_of_Matt_Hazard"],["Echochrome"],["Ecks_vs._Sever"],["Edge_of_Twilight"],["Ehrgeiz"],["Einhander"],["Elasto_Mania"],["The_Elder_Scrolls"],["The_Elder_Scrolls:_Arena"],["The_Elder_Scrolls_2:_Daggerfall"],["The_Elder_Scrolls_3:_Morrowind"],["The_Elder_Scrolls_3:_Bloodmoon"],["The_Elder_Scrolls_3:_Tribunal"],["The_Elder_Scrolls_4:_Oblivion"],["Elefunk_(video_game)"],["Elevator_Action"],["Elite_(computer_game)"],["Elveon"],["Elvira"],["Elysaria"],["Ember_(video_game)"],["Emergency_Hospital_(video_game)"],["Emergency_Mayhem"],["E-Motion"],["Emlyn_Hughes_International_Soccer"],["Empire_(computer_game)"],["Empire:_Alpha_Complex"],["Enchanted_Arms"],["Enemy_Territory:_Quake_Wars"],["Enzai"],["Escape_from_the_Planet_of_the_Robot_Monsters"],["Escape_Velocity_(computer_game)"],["ESPN_Final_Round_Golf_2002"],["E.T._(video_game)"],["Eternal_Champions"],["Eternal_Sonata"],["Ethnic_Cleansing_(computer_game)"],["E-Type_(game)"],["Eureka!_(computer_game)"],["Europa_Universalis"],["EVE_Online"],["Evernight"],["EverQuest"],["Everyday_Shooter"],["Everyone%27s_A_Wally"],["Everything_or_Nothing_(video_game)"],["Excitebike"],["Excitebike"],["Exile_(video_game)"],["Exile_(arcade_adventure)"],["Exile_(computer_game)"],["Exile_II:_Crystal_Souls"],["Blades_of_Exile"],["Eye_of_Horus"],["The_Eye_of_Judgment"],["Eye_of_the_Beholder_(computer_game)"],["F1_Grand_Prix_(2005_video_game)"],["F-14_Tomcat"],["F-15_Strike_Eagle_(video_game)"],["F-19_Stealth_Fighter"],["Fable"],["Fable_The_Lost_Chapters"],["Fable_2"],["FaceBreaker"],["Faces_of_War"],["Fade_(computer_game)"],["Fade_to_Black_(video_game)"],["The_Fairly_OddParents:_Shadow_Showdown"],
		["The_Fairly_OddParents:_Breakin%27_Da_Rules"],["Faith_and_a_.45"],["Falcon_(computer_game)"],["Fallout_(computer_game)"],["Fallout_(computer_game)"],["Fallout_Tactics"],["Fallout_3"],["Fantasy_General"],["Fantasy_Wars"],["Fantasy_Zone"],["Fantastic_Four_(1997_video_game)"],["Fantastic_Four_(2005_video_game)"],["Fantastic_Four:_Rise_of_the_Silver_Surfer_(video_game)"],["Fantastic_Four_TV_game"],["Far_Cry"],["Far_Cry_2"],["Far_Cry_Instincts"],["Fat_Princess"],["Fatal_Racing"],["Fate_(1996_game)"],["Fate_(video_game)"],["Fate:_Gates_of_Dawn"],["F.E.A.R._(computer_game)"],["F.E.A.R._2:_Project_Origin"],["Feel_Ski"],["Feel_the_Magic:_XY/XX"],["Ferazel%27s_Wand"],["Ferrari_Challenge_(video_game)"],["Fields_of_Glory"],["FIFA_Manager"],["FIFA_Manager_06"],["FIFA_Manager_07"],["FIFA_Manager_08"],["FIFA_series"],["FIFA_Soccer_Manager"],["FIFA_Street"],["FIFA_Street_2"],["FIFA_Street_3"],["Fifth_Phantom_Saga"],["Fighter_Ace"],["Fight_Night:_Round_2"],["Fight_Night_2004"],["Fight_Night_Round_3"],["Fight_Night_Round_4"],["Final_Fantasy"],["Final_Fantasy_(video_game)"],["Final_Fantasy_II"],["Final_Fantasy_III"],["Final_Fantasy_IV"],["Final_Fantasy_IV_the_After:_Tsuki_no_Kikan"],["Final_Fantasy_V"],["Final_Fantasy_VI"],["Final_Fantasy_Collection"],["Final_Fantasy_Chronicles"],["Final_Fantasy_Anthology"],["Final_Fantasy_VII"],["Compilation_of_Final_Fantasy_VII"],["Before_Crisis_-Final_Fantasy_VII-"],["Crisis_Core_-Final_Fantasy_VII-"],["Dirge_of_Cerberus_-Final_Fantasy_VII-"],["Dirge_of_Cerberus_Lost_Episode_-Final_Fantasy_VII-"],["Final_Fantasy_VII_Snowboarding"],["Final_Fantasy_VIII"],["Final_Fantasy_IX"],["Final_Fantasy_X"],["Final_Fantasy_X-2"],["Final_Fantasy_XI"],["Final_Fantasy_XI:_Chains_of_Promathia"],["Final_Fantasy_XI:_Rise_of_the_Zilart"],["Final_Fantasy_XI:_Treasures_of_Aht_Urhgan"],["Final_Fantasy_XII"],["Ivalice"],["Final_Fantasy_Tactics"],["Final_Fantasy_Tactics_Advance"],["Final_Fantasy_Tactics_A2_F%C5%ABketsu_no_Grimoire"],["Final_Fantasy_XII_Revenant_Wings"],["Fabula_Nova_Crystallis_Final_Fantasy_XIII"],["Final_Fantasy_XIII"],["Final_Fantasy_Agito_XIII"],["Final_Fantasy_Versus_XIII"],["Fabula_Nova_Crystallis_Final_Fantasy_XIII"],["Final_Fantasy_Adventure"],["Final_Fantasy_Crystal_Chronicles_(series)"],
		["Final_Fantasy_Crystal_Chronicles"],["Final_Fantasy_Crystal_Chronicles:_Ring_of_Fates"],["Final_Fantasy_Crystal_Chronicles:_The_Crystal_Bearers"],["SaGa"],["Final_Fantasy_Legend"],["Final_Fantasy_Legend_II"],["Final_Fantasy_Legend_III"],["Final_Fantasy_Mystic_Quest"],["Final_Fight"],["Final_Fight"],["Final_Fight_One"],["Final_Lap"],["Fire_and_Ice_(computer_game)"],["Fire_Brigade"],["Fire_Emblem"],["Fire_Emblem"],["Fire_Emblem_Gaiden"],["Fire_Emblem:_Monshou_no_Nazo"],["Fire_Emblem:_Seisen_no_Keifu"],["Fire_Emblem:_Thracia_776"],["Fire_Emblem:_Fuuin_no_Tsurugi"],["Fire_Emblem_(Game_Boy_Advance)"],["Fire_Emblem:_The_Sacred_Stones"],["Fire_Emblem:_Path_of_Radiance"],["Fire_Emblem:_Radiant_Dawn"],["The_Firemen"],["Fire_Pro_Wrestling"],["Fish_Tycoon"],["First_Battalion"],["FlightGear"],["Flight_Unlimited"],["Flimbo%27s_Quest"],["Flipper_and_Lopaka"],["Flipull/Plotting"],["Flock_(video_game)"],["Flood_(computer_game)"],["Flow_(video_game)"],["Flower_(video_game)"],["Flying_Shark"],["Foes_of_Ali"],["Folklore_(video_game)"],["FooBillard"],["Food_Fight_(video_game)"],["Formula_One_(game)"],["Formula_1_(PS1)"],["Formula_1_97"],["Formula_1_98"],["Formula_One_04"],["Formula_One_05"],["Formula_One_06"],["Formula_One_99"],["Formula_One_2000"],["Formula_One_2001"],["Formula_One_2002"],["Formula_One_2003"],["Formula_One_Arcade"],["Formula_One_Championship_Edition"],["Fort_Apocalypse"],["Fountain_of_Dreams"],["Fracture_(video_game)"],["Frak!"],["Freakin%27_Funky_Fuzzballs"],["Freddy%27s_Rescue_Roundup"],["FreeCell"],["Freeciv"],["Free_Realms"],["Descent:_FreeSpace_%E2%80%94_The_Great_War"],["FreeSpace_2"],["Freelancer_(video_game)"],["Frequency_(game)"],["Frogger"],["Frogger_II"],["Frogger_3D"],["Frogger_2:_Swampy%27s_Revenge"],["Frogger%27s_Adventures:_The_Rescue"],["Frogger:_Ancient_Shadow"],["Frogger_Beyond"],["Frogger:_Helmet_Chaos"],["From_Russia_with_Love_(video_game)"],["Frontier_(computer_game)"],["Front_Line_(arcade_game)"],["Frontlines:_Fuel_of_War"],["Fuel_(2009_video_game)"],["Full_Auto"],["Full_Auto_2:_Battlelines"],["Full_Spectrum_Warrior"],["Full_Throttle_(computer_game)"],["Fury_of_the_Furries"],["Futurama_(game)"],["Future_Tactics:_The_Uprising"],["Future_Wars"],["F-Zero_series"],["F-Zero"],["F-Zero_GX"],["F-Zero_X"],["F-Zero:_Maximum_Velocity"],["G1_Jockey_4_2007"],["Galactic_(computer_game)"],["Galactic_Civilizations"],["Galaga"],["Galatea_(computer_game)"],["Galaxian"],["Galaxy_Trek"],["Garfield:_A_Big_Fat_Hairy_Deal"],["Gary_Grigsby%27s_Pacific_War"],["Gateway_to_Apshai"],["Gauntlet_(arcade_game)"],["Gauntlet_II"],["Gauntlet_Legends"],["Gauntlet:_Dark_Legacy"],["Gauntlet:_Seven_Sorrows"],["Geist_(video_game)"],["Gemstone_Warrior"],["Gemstone_Healer_(game)"],["Gem%27X"],["Geneforge_series"],["Genghis_Khan_(video_game)"],["Genji:_Days_of_the_Blade"],["Geon:_Emotions"],["The_Getaway_(video_game)"],["Gettysburg_(computer_game)"],["Gex_(video_game_series)"],["Ghostbusters:_The_Video_Game"],["Ghost_Recon"],["Tom_Clancy%27s_Ghost_Recon"],["Tom_Clancy%27s_Ghost_Recon_2"],["Tom_Clancy%27s_Ghost_Recon_2:_Summit_Strike"],["Tom_Clancy%27s_Ghost_Recon:_Advanced_Warfighter"],["Ghostbusters_(Sega_video_game)"],["Ghosts_%27n_Goblins"],["Ghouls_%27n_Ghosts"],["Gladiator"],["Gladius"],["Global_Operations"],["Gloom_(game)"],["GlTron"],["Gnop!"],["GNU_Chess"],["GNU_Go"],["Go!_Go!_Hypergrind"],["Go!_Puzzle"],["Go!_Sudoku"],["Goblin_Commander:_Unleash_the_Horde"],["Gobliiins"],["Gobliiins"],["Gobliins_2"],["Goblins_3"],["The_Godfather:_The_Game"],["The_Godfather_II_(video_game)"],["God_of_War"],["God_of_War_II"],["Gods_(computer_game)"],["Godzilla:_Destroy_All_Monsters_Melee"],["Golden_Axe_(series)"],["Golden_Axe"],["Golden_Axe_II"],["Golden_Axe_III"],["Golden_Axe:_Beast_Rider"],["Golden_Axe:_The_Duel"],["Golden_Axe:_The_Revenge_of_Death_Adder"],["Golden_Axe_Warrior"],["The_Golden_Compass_(video_game)"],["Golden_Sun"],["Golden_Sun"],["Golden_Sun"],["GoldenEye_007"],["Golf_(video_game)"],["Golf_(video_game)"],["Golgo_13:_Top_Secret_Episode"],["The_Goonies"],["Gotcha_Force"],["Gothic_(computer_game)"],["Gradius"],["Gradius_Generation"],["Gran_Turismo_(game)"],["Granny%27s_Garden"],["Gran_Turismo_5"],["Grand_Prix_4"],["Grand_Prix_Legends"],["Grand_Theft_Auto_(series)"],["Grand_Theft_Auto_(game)"],["Grand_Theft_Auto:_London,_1969"],["Grand_Theft_Auto_2"],["Grand_Theft_Auto_III"],["Grand_Theft_Auto:_Vice_City"],["Grand_Theft_Auto:_San_Andreas"],["Grand_Theft_Auto:_Liberty_City_Stories"],["Grand_Theft_Auto:_Vice_City_Stories"],
		["Grand_Theft_Auto_IV"],["Grandia"],["Grandia_2"],["Grandia_3"],["Gravitar_(arcade_game)"],["Great_Giana_Sisters"],["Grim_Fandango"],["GripShift"],["Grooverider:_Slot_Car_Thunder"],["Ground_Control"],["Ground_Control"],["Ground_Control_II:_Operation_Exodus"],["Gruntz"],["GT_Advance_Championship_Racing"],["GT_Advance_2:_Rally_Racing"],["GT_Advance_3:_Pro_Concept_Racing"],["GTI_Club%2B:_Rally_C%C3%B4te_d%27Azur"],["The_Guild_2"],["Guild_Wars"],["Guild_Wars"],["Guild_Wars:_Factions"],["Guild_Wars_Nightfall"],["Guilty_Gear"],["Guilty_Gear"],["Guilty_Gear_X"],["Guilty_Gear_XX"],["Guilty_Gear_XX#reload"],["Guilty_Gear_XX_Slash"],["Guilty_Gear_XX_Accent_Core"],["Guitar_Hero"],["Guitar_Hero_(video_game)"],["Guitar_Hero_II"],["Guitar_Hero_Encore:_Rocks_the_80s"],["Guitar_Hero_III:_Legends_of_Rock"],["Guitar_Hero:_Aerosmith"],["Guitar_Hero:_Greatest_Hits"],["Guitar_Hero:_Metallica"],["Guitar_Hero_III_Mobile"],["Guitar_Hero:_On_Tour"],["Guitar_Hero:_On_Tour_Decades"],["Guitar_Hero_World_Tour"],["Gun_(video_game)"],["Gunfright"],["Gungrave"],["Gunmetal_(PC)"],["Gunroar"],["Gunship_(game)"],["Gunship_2000"],["Gunstar_Heroes"],["The_Guy_Game"],["Gyruss"],[".hack_(video_games)"],["Hack_(video_game)"],["Half-Life_(computer_game)"],["Half-Life_(computer_game)"],["Half-Life:_Opposing_Force"],["Half-Life:_Blue_Shift"],["Half-Life:_Decay"],["Half-Life:_Source"],["Half-Life_2"],["Half-Life_2:_Episode_One"],["Half-Life_2:_Episode_Two"],["Half-Life_2:_Episode_Three"],["Half-Life_2:_Lost_Coast"],["Halo_(series)"],["Halo:_Combat_Evolved"],["Halo_2"],["Halo_3"],["Halo_Wars"],["Happy_Tree_Friends:_False_Alarm"],["Hardball_(computer_game)"],["Hard_Hat_Mack"],["Hardwar"],["Harlequin_(computer_game)"],["Harpoon_(computer_game)"],["Harvest_Moon_(series)"],["Harvest_Moon_(game)"],["Hawks_%26_Doves_Videogame"],["Head_Over_Heels_(game)"],["Heart_of_Africa"],["Heart_of_Darkness"],["Hearts_of_Iron"],["Hearts_of_Iron_II"],["Heavenly_Sword"],["Heavy_Gear"],["Heavy_on_the_Magick"],["Heavy_Rain"],["Heiankyo_Alien"],["Helbreath"],["Heretic_(computer_game)"],["Heretic_II"],["H.E.R.O."],["Hexen"],["Hexen_II"],["Heroes_of_Annihilated_Empires"],["Heroes_of_Might_and_Magic"],["Hidden_and_Dangerous"],["High_Command"],["High_Heat_Baseball"],["High_Stakes_on_the_Vegas_Strip:_Poker_Edition"],["High_Velocity_Bowling"],["Hired_Guns"],["Shootout_the_Game"],["Hitman_(computer_game_series)"],["The_Hobbit_(video_game)"],["The_Hobbit_(Vivendi_Game)"],["Homeworld"],["Homeworld:_Cataclysm"],["Homeworld_2"],["Hoppin%27_Mad"],["Horace_Series"],["Hostile_Waters_(game)"],["The_House_of_the_Dead_(arcade_game)"],["The_House_of_the_Dead_2"],["The_House_of_the_Dead_III"],["The_House_of_the_Dead_4"],["Hovertank_3D"],["Hugo%27s_House_of_Horrors"],["Hunchback"],["Hunt_(computer_game)"],["Hunt_for_Red_October"]]
		@ambig = []
			@ar.each do |ar| 
				@n = Nuniverse.find_by_wikipedia_id(ar[0])
					
						doc = Hpricot open "http://en.wikipedia.org/wiki/#{ar[0]}?action=render"
						title = (doc/"table.infobox"/"th.summary"/"i").first.inner_html rescue CGI::unescape(ar[0].gsub('_',' '))
						image = (doc/"table.infobox"/"img").first.attributes['src'] rescue nil 
						genres = []
						developers = []
						publishers =[]
						 (doc/"table.infobox"/"tr").each do |tr|
							
							unless (tr/:a).empty?
								case (tr/:a)[0].attributes['href']
								when "http://en.wikipedia.org/wiki/Video_game_genres"	
									(tr/'td:nth(1)'/:a).each do |genre|
										genres << Tag.find_or_create(:name => genre.inner_html)
									end
								when "http://en.wikipedia.org/wiki/Video_game_developer"
									(tr/'td:nth(1)'/:a).each do |dev|
										wid = dev.attributes['href'].gsub('http://en.wikipedia.org/wiki/','')
									
										d = Nuniverse.find_by_wikipedia_id(wid)
										
										d = Nuniverse.find_or_create(:name => dev.inner_html, :uniqe_name => wid, :wikipedia_id => wid) if d.nil?
									
										d.tags << d_tag rescue nil
										developers << d
									end
								when "http://en.wikipedia.org/wiki/Video_game_publisher"
									(tr/'td:nth(1)'/:a).each do |dev|
											wid = dev.attributes['href'].gsub('http://en.wikipedia.org/wiki/','')

											p = Nuniverse.find_by_wikipedia_id(wid)
											p = Nuniverse.find_or_create(:name => dev.inner_html, :unique_name => wid, :wikipedia_id => wid) if p.nil?
											p.tags << p_tag rescue nil
											publishers << p
									end
								end
							end	
								
							
						end
								
						begin 
						if @n.nil?
							@n = Nuniverse.create(:name => title, :unique_name => Token.sanatize(title), :wikipedia_id => ar[0]) 
							@n.tags << [tag1]
						end
						@n.tags << genres rescue nil
						@n.connections << developers rescue nil
						@n.connections << publishers rescue nil
						
						
						
						if  !image.blank?
							@image = Image.find_or_create(:source_url =>image)
							@n.images << @image rescue nil
						end
					rescue
						@ambig << ar
					end
					

		end
	end
	
	
	def batch_4 
		@tags = Tag.find(:all, :conditions => ["name rlike ?", "^arcade[\s\-\/]racing(\sgame)?"])
		
		@tag3 = Tag.find_by_name('arcade')
		@tag4 = Tag.find_by_name('racing')
		
		@bandtag = Tag.find_by_name('')
		@bands = Nuniverse.search(:with => {:tag_ids => @tags.collect{|c| c.id}.to_a}, :per_page => 200, :page => 1)
		@bands.each do |band|
			band.tags.delete @tags rescue nil
			band.tags << [@tag3, @tag4] rescue nil
		end
	end
		
		
	def batch_3
	
	  
	 
		@actresses = Nuniverse.find(:all, :conditions => "id > 101813")
		# @bot = RWikiBot.new('u','p','http://en.wikipedia.org/w/api.php')
		# @page = @bot.page("#{actress.wikipedia_id}")
		@actresses.each do |actress|
			
			doc = Hpricot open "http://en.wikipedia.org/wiki/#{actress.wikipedia_id}?action=render"
			image = (doc/:table/:img).first.attributes['src'] rescue nil
		
			# image = @page.content.scan(/image\s\=\s(.*)\.(jpg|png)/).flatten
			# 	
			# 		hash = Digest::MD5.hexdigest(image[0])
			# 		raise hash.inspect
			# 		path = "#{hash[0..0]}/#{hash[0..1]}/#{image[0].gsub(' ','_')}.#{image[1]}"
			# 	raise path.inspect
			if  !image.blank?
				
				
			
				@image = Image.find_or_create(:source_url =>image)
			
				actress.images << @image rescue nil
			else 
			
			end
			
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

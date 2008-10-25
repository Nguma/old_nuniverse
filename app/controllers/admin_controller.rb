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
	
	def ct 
		cts = [
			["Spider-Man 3","Shrek the Third","Transformers","Pirates of the Caribbean: At World's End","Harry Potter and the Order of the Phoenix","I Am Legend","The Bourne Ultimatum","National Treasure: Book of Secrets","Alvin and the Chipmunks","300","Ratatouille","The Simpsons Movie","Wild Hogs","Knocked Up","Juno","Rush Hour 3","Live Free or Die Hard","Fantastic Four: Rise of the Silver Surfer","American Gangster","Enchanted","Bee Movie","Superbad","I Now Pronounce You Chuck and Larry","Hairspray","Blades of Glory","Ocean's Thirteen","Ghost Rider","Evan Almighty","Meet the Robinsons","Norbit","The Bucket List","The Game Plan","Bridge to Terabithia","Beowulf","Disturbia","No Country for Old Men","Fred Claus","1408","The Golden Compass","Charlie Wilson's War","Saw IV","Stomp the Yard","Surf's Up","Halloween","Tyler Perry's Why Did I Get Married","TMNT","P.S. I Love You","3:10 to Yuma","Sweeney Todd: The Demon Barber of Fleet Street","Atonement","Resident Evil: Extinction","Music and Lyrics","Are We Done Yet?","This Christmas","Michael Clayton","Premonition","Dan in Real Life","The Kingdom","Shooter","License to Wed","Underdog","No Reservations","Because I Said So","Aliens Vs. Predator - Requiem","The Water Horse: Legend of the Deep","There Will Be Blood","Epic Movie","Hitman","30 Days of Night","Fracture","Stardust","The Brave One","The Heartbreak Kid","Freedom Writers","Smokin' Aces","The Messengers","The Number 23","Good Luck Chuck","Mr. Bean's Holiday","Breach","Zodiac","Balls of Fury","Mr. Magorium's Wonder Emporium","August Rush","Tyler Perry's Daddy's Little Girls","The Great Debaters","28 Weeks Later","We Own the Night","Mr. Brooks","Hannibal Rising","The Nanny Diaries","Mr. Woodcock","Nancy Drew","The Mist","The Reaping","Grindhouse","Sicko","Across the Universe","Perfect Stranger","Hot Fuzz","WAR","The Last Mimzy","Amazing Grace","The Hills Have Eyes 2","The Invisible","Reno 911!: Miami","Gone Baby Gone","Reign Over Me","Sea Monsters: A Prehistoric Adventure (IMAX)","Vacancy","Georgia Rule","Waitress","Becoming Jane","Into the Wild","Walk Hard: The Dewey Cox Story","Next","Hostel Part II","Eastern Promises","Dead Silence","The Hitcher (2007)","Elizabeth: The Golden Age","The Kite Runner","Happily N'Ever After","Catch and Release","Alpha Dog","The Invasion","Lions for Lambs","Awake","Hot Rod","Firehouse Dog","The Namesake","The Comebacks","Daddy Day Camp","Shoot 'Em Up","I Think I Love My Wife","Evening","The Darjeeling Limited","Sydney White","The Lives of Others","In the Land of Women","The Astronaut Farmer","Dragon Wars","Primeval","La Vie en Rose","Pathfinder: Legend of the Ghost Warrior","BRATZ","Rendition","Death Sentence","Once"]
		]
		cts.each_with_index do |ct,i|
			ct.each do |m|
				t = Tag.new(:label => m, :kind => 'film', :data => "#country US #release_date #{2001+i}")
				t.save
				Tagging.create(:subject_id => 0, :object_id => t.id, :user_id => 0, :kind => 'film', :public => 1)
			end
		end
	end
end

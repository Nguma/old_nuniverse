require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles

	# belongs_to :role, :class_name => "Role"
	# has_one :max_connections, :through => :role
	
  #validates_presence_of     :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :login, :case_sensitive => false,
																		:message	=> "Sorry, but someone already ses that login. Please choose another one."

  validates_format_of       :login, :with     => Authentication.login_regex,
                                    :message  => Authentication.bad_login_message

  # validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  # validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email, :case_sensitive => false, 
																		:message => "An account already exists with this email. Is it yours? <a href='/login'>Log in</a>"
  validates_format_of       :email, :with     => Authentication.email_regex,
                                    :message  => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation

	has_many :connecteds, :as => :subject, :class_name => "Polyco"
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :nuniverse_connections, :as => :object, :class_name => "Polyco", :conditions => "polycos.object_type = 'Nuniverse'"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :bookmarks, :through => :connections, :source => :subject, :source_type => "Bookmark"
	has_many :comments, :through => :connections, :source => :subject, :source_type => "Comment"
	has_many :facts,:through => :connections, :source => :subject, :source_type => 'Fact'
	has_many :tastemakers, :through => :connections, :source => :subject , :source_type => "User"
	# has_many :groups, :through => :connections, :source => :subject, :source_type => "Group"
	
	has_many :boxes, :as => :parent
	has_many :collections, :as => :parent

	alias_attribute :name, :login
	alias_attribute :unique_name, :login

	has_many :taggings, :as => :taggable
	has_many :tags, :through => :taggings
	
	has_many :reviews, :class_name => "Comment", :foreign_key => :user_id	
	
	has_many :rankings, :class_name => "Ranking", :foreign_key => :user_id
	
	def pros
		comments.pros
	end
	
	

	alias_attribute :title, :label
	
	define_index do
		indexes :login, :as => :identifier
		indexes [:firstname, :lastname], :as => :name, :sortable => true
		indexes taggings(:tag).name, :as => :tags
		# has connections(:id), :as => :c_id
		has tags(:id), :as => :tag_ids
		has :state
		set_property :suggestable => true
		set_property :delta => true
		
	end
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    # u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u = find(:first,:conditions => {:login => login})
		u && u.authenticated?(password) ? u : nil
  end

	def connected_to?(nuniverse)
		connections.of_klass('Nuniverse').with_subject(nuniverse).first
	end

	def redirect
		return nil
	end
	
	def label
		return login.capitalize if login
		return email
	end
	

	
	def avatar(params = {})
		connections.of_klass('Image').first.subject.public_filename(params[:size]) rescue nil
	end
	
	def poker_face(params = {})
		connections.of_klass('Image').tagged(Tag.find_by_name('default')).first.subject.public_filename(params[:size]) rescue avatar(:size => params[:size])
	end
	
	def very_good_face(params = {})
		connections.of_klass('Image').tagged(Tag.find_by_name('rank5')).first.subject.public_filename(params[:size])  rescue nil
	end
	
	def good_face(params = {})
		connections.of_klass('Image').tagged(Tag.find_by_name('goodface')).first.subject.public_filename(params[:size])  rescue nil
	end
	
	def bad_face(params = {})
		connections.of_klass('Image').tagged(Tag.find_by_name('badface')).first.subject.public_filename(params[:size]) rescue nil
	end
	
	def very_bad_face(params = {})
		connections.of_klass('Image').tagged(Tag.find_by_name('rank0')).first.subject.public_filename(params[:size]) rescue nil
	end

	
	def connections_count 
		Tagging.count(:select => "DISTINCT object_id", :conditions => ['user_id = ?',self.id])
	end
	
	def invite(params)
		Permission.create(
			:grantor_id => self.id,
			:granted_id => params[:user].id,
			:tags => params[:to].name)
		UserMailer.deliver_invitation(:to => params[:to], :user => params[:user], :message => params[:message] || "", :sender => self)
	end
	
	def email_to(params)
		params[:sender] ||= self
		UserMailer.deliver_list(params)		
	end
	

	
	def score
		(rankings.average(:score)) rescue nil
	end
	
	def stat(params)
		return Stat.new(:score => params[:score], :value => rankings.count(:conditions  => ['score = ?', params[:score]]), :total => rankings.count)
	end
	
	
	def categories
		Tag.search(:conditions => {:object_id => self.id, :object_type => 'User' }, :per_page => 10)
	end


	def add_image(params)
		tag.add_image(params)
	end
	
	def users
		Connection.with_subject_kind('user').with_object(self.tag).collect {|c| c.subject }
	end
	
	
	def latest_review
		reviews.last
	end
	
	def voting_stats
		return [] if rankings.empty?
		rankings_by_score = rankings.group_by(&:score)
		stats = []
		11.times do |t|
			rankings_by_score[t] =  rankings_by_score[t] ? rankings_by_score[t] : [] 
		end
		rankings_by_score.collect {|s,v| {'score' => s.round,'count' => v.length, 'percent' => (v.length * 100)/rankings.count} }
	end
	
	def is_following?(user)
		return self.tastemakers.find_by_id(user.id)
	end

	def add(element, params = {})
		connection = Polyco.find_or_create(:object => self, :subject => element)
		begin
			connection.tags << params[:tags].collect {|t| Tag.find_or_create(:name => t)} if params[:tags]
		rescue 
		end
	end
	
  protected
    
    def make_activation_code
    	self.deleted_at = nil
      self.activation_code = self.class.make_token
    end

	
end



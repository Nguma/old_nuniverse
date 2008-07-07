require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

	has_one :asset
	belongs_to	:tag, :class_name => "Tag", :foreign_key => "tag_id", :dependent => :destroy

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

	#validates_presence_of     :password_confirmation,      :if => :password_required?
  #validates_confirmation_of :password,                   :if => :password_required?
  before_save :encrypt_password

  after_create :ontologize
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :firstname, :lastname #:password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

	def avatar
		if asset.image?
			image_tag(asset.public_filename(:thumb))
		else
		
		end
	end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

	def ontologize
		#ont = "#user #{self.login} #topic About Me #category My Topics #category My Contacts"
		#	gumies = ont.scan(/\s*#([\w_]+)[\s]+([^#|\[|\]]+)*/) # separates gumi type from its content
		#gumies = ont.scan(/\s*#([\w_]+[\s]+[^#|\[|\]]+)*/) 
		self.tag = Tag.new(:content => self.login, :kind => "user", :description => "")#find_or_create_by_gumi("##{gumies.shift}")
		
		#gumies.each do |gumi|
		#	self.tag.connect_with(Tag.find_or_create_by_gumi("##{gumi}"))
		#end
		self.save
	end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end

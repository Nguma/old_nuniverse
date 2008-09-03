require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles
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

	has_one :asset
	belongs_to :tag
	
	after_create :assign_tag
	
	has_many :invitations, :class_name => "Permission", :foreign_key => "user_id"


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

	def avatar
		if asset.image?
			image_tag(asset.public_filename(:thumb))
		else	
		end
	end
	
	def max_connections
		case self.role
		when "free"
			return 200
		when "admin"
			return 9999999
		end
	end
	
	def connections_count 
		Tagging.count(:conditions => ['user_id = ?',self.id])
	end
	
	def invite(params)
		Permission.create(
			:tagging => params[:topic],
			:user => params[:user])
		UserMailer.deliver_invitation(:topic => params[:topic], :user => params[:user], :sender => self)
	end
	
	def address
		tag.property('address')
	end
	
	def connections(params = {})
		Tagging.with_user(self).with_kind_like(params[:kind]||nil).with_order(params[:order] || nil).paginate(:page => params[:page] || 1, :per_page => 10)
	end
	

  protected
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end

		def assign_tag
			return if self.login.nil?
			self.tag = Tag.create(
				:label => self.login,
				:kind => 'user'
			)
			self.save
		end

end



class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://localhost:3000"
  end

	def invitation(params)
		@recipients  = params[:user].email
    @from        = params[:sender].email
    @subject     = "#{params[:sender].login.capitalize} is inviting you."
    @sent_on     = Time.now
    @body[:sender] = params[:sender]
		@body[:topic] = params[:topic]
		@body[:url] = "http://localhost:3000/taggings/#{params[:topic].id}"
		
	end
	
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "do-not-reply@nuniverse.net"
      @subject     = "Nuniverse - "
      @sent_on     = Time.now
      @body[:user] = user
    end
end

class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
		@subject += "You just signed up for a beta account"
		@bcc = "beta@nuniverse.net"
  end 
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://www.nuniverse.net"
  end

	def feedback(params)
		@subject = "Nuniverse - feedback"
		@from = params[:user].email rescue params[:ip]
		@recipients = "feedback@nuniverse.net"
		@sent_on = Time.now
		@body[:feedback] = params[:feedback]
		@body[:user_info] = params[:ip]
		@body[:user_info] += " - #{params[:user].login}" if params[:user]
		
	end

	def invitation(params)
		@recipients  = params[:user].email
    @from        = params[:sender].email
    @subject     = "#{params[:sender].login.capitalize} is inviting you."
    @sent_on     = Time.now
    @body[:sender] = params[:sender]
		@body[:topic] = params[:topic]
		@body[:url] = "http://www.nuniverse.net/taggings/#{params[:topic].id}"
		
	end
	
	def activation_code(user)
		setup_email(user)
		@subject    += 'Please activate your new account'
		@body[:user] = user
    @body[:url]  = "http://www.nuniverse.net/activate/#{user.activation_code}"
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

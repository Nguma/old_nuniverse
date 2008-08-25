class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://localhost:3000/"
  end

	def invitation(tagging, params = {})
		@recipients  = params[:email]
    @from        = params[:from].email
    @subject     = "#{current_user.login.capitalize} is inviting you."
    @sent_on     = Time.now
    @body[:user] = params[:from]
		@body[:url] = "http://localhost:3000/taggings/#{tagging.id}"
		
	end
	
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "do-not-reply@localhost:3000"
      @subject     = "Nuniverse - "
      @sent_on     = Time.now
      @body[:user] = user
    end
end

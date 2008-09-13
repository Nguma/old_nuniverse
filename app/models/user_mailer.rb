class UserMailer < ActionMailer::Base
	
	def initialize_defaults(method_name)
	    super(method_name)
	    @content_type = 'multipart/related; type=text/html'
	end
  
  def signup_notification(user)
    setup_email(user)
		@subject += "You just signed up for a beta account"
  end 
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://www.nuniverse.net/my_nuniverse"
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
		@body[:to] = params[:to]
		@body[:url] = "http://www.nuniverse.net/my_nuniverse/#{params[:to].label}"
		@body[:message] = params[:message]
		@body[:items] = params[:to].items(:page => 1, :per_page => 8)
		
		TMail::HeaderField::FNAME_TO_CLASS.delete 'content-id'
		
		@body[:items].each_with_index do |item,i|

		
			part 	:content_type => "text/html",
			      		:body => render_message('invitation.text.html.erb', @body)
		
			unless item.object.thumbnail.blank?
				inline_attachment :content_type => "image/jpeg", 
				                  :body => File.read("#{RAILS_ROOT}/public/#{item.object.thumbnail}"),
				                  :filename => item.object.thumbnail,
				                  :cid => "<#{item.object.thumbnail}@nuniverse.net>"
			end
		end
		
		
		# inline_attachment :content_type => "image/jpeg",
		# 										:body => File.read("http://maps.google.com/staticmap?center=40.718,-73.998672&span=0.05,0.05&markers=40.700147,-74.015794,bluea|&maptype=mobile&size=400x400&key=ABQIAAAA8l8NOquAug7TyWVBqeUUKBTJQa0g3IQ9GZqIMmInSLzwtGDKaBTkRKFsYU1nJXs7m0cuhHHmMYXxNg"),
		# 										:filename => "google_map",
		# 										:cid => "<map@google.com>"
		# 										
	end
	
	def activation_code(user)
		setup_email(user)
		@subject    += 'Your activation code'
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
			headers         "Reply-to" => "do-not-reply@nuniverse.net"
			
    end

		def inline_attachment(params, &block) 
		 	params = { :content_type => params } if String === params 
		 	params = { :disposition => "inline", 
		 	          :transfer_encoding => "base64" }.merge(params) 
		 	params[:headers] ||= {} 
		 	params[:headers]['Content-ID'] = params[:cid] 
		 	part(params, &block) 
		end
end

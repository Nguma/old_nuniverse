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
	
		@body[:url] = "http://www.nuniverse.net/my_nuniverse/all/#{params[:to].label}"
		@body[:message] = params[:message]
		@body[:items] = params[:items]
		part 	:content_type => "text/html",
		      :body => render_message('invitation.text.html.erb', @body)
		include_thumbnails(@body[:items])			
						
	end
	
	def story(params)
		@recipients  = params[:emails]
    @from        = params[:sender].email
    @subject     = "#{params[:sender].login.capitalize} is sharing a story with you."
    @sent_on     = Time.now
    @body[:sender] = params[:sender]
		@body[:content] = params[:story]
		@body[:title] = params[:story].name
		@body[:url] = "http://www.nuniverse.net/stories/#{params[:story].id}"
		@body[:message] = params[:message]
		@body[:items] = params[:story].connections
		part 	:content_type => "text/html",
		      :body => render_message('story.text.html.erb', @body)
		include_thumbnails(@body[:items])
	end
	
	
	def list(params)
		@recipients  = params[:emails]
    @from        = params[:sender].email
    @subject     = "#{params[:sender].login.capitalize} is sharing his nuniverse with you."
    @sent_on     = Time.now
    @body[:sender] = params[:sender]
		@body[:content] = params[:tag]
		@body[:title] = params[:tag].label
		@body[:url] = "http://www.nuniverse.net/my_nuniverse/all/#{@body[:title]}"
		@body[:message] = params[:message]
		@body[:items] = params[:connections] || params[:tag].connections(:page => 1, :per_page => 10)
		part 	:content_type => "text/html",
		      :body => render_message('list.text.html.erb', @body)
		include_thumbnails(@body[:items])		
		
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
			TMail::HeaderField::FNAME_TO_CLASS.delete 'content-id'
    end

		def inline_attachment(params, &block) 
		 	params = { :content_type => params } if String === params 
		 	params = { :disposition => "inline",
		 	          :transfer_encoding => "base64" }.merge(params) 
		 	params[:headers] ||= {} 
		 	params[:headers]['Content-ID'] = params[:cid] 
		 	part(params, &block) 
		end
		
		def include_nuniverse_icon
			inline_attachment :content_type => "image/png", 
			                  :body => File.read("#{RAILS_ROOT}/public/images/backgrounds/icon.png"),
			                  :filename => "icon_bg",
			                  :cid => "<icon_bg@nuniverse.net>"
		end
		
		
		def include_thumbnails(items)
			items.each_with_index do |item,i|
				unless item.subject.avatar.nil?
					inline_attachment :content_type => "image/jpeg", 
					                  :body => File.read("#{RAILS_ROOT}/public/#{item.subject.avatar(:small)}"),
					                  :filename => item.subject.avatar(:small),
					                  :cid => "<#{item.subject.avatar(:small)}@nuniverse.net>"
				end
			end
		end
end

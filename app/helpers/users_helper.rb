module UsersHelper
	
	def account_for(user, options = {}, &block)
		content = capture(&block)
    concat(
      render(
        :partial => '/users/account',
        :locals => {:user => user, :content => content}
      ), block.binding
    )
	end
end
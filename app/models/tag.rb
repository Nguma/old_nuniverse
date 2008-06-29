class Tag < ActiveRecord::Base
	
	validates_presence_of :content, :kind
end

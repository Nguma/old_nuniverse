class Tag < ActiveRecord::Base
  has_one :avatar
  	
	validates_presence_of :content, :kind

end

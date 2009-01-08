class Tag < ActiveRecord::Base
	has_many :connections, :as => :subject, :class_name => "Polyco"
	
	def self.find_or_create(params)
		Tag.find(:first, :conditions => {:name => params[:name]}) || Tag.create(:name => params[:name]) 
	end
	
	def avatar
		return nil
	end
	
	def tags
		[]
	end

end

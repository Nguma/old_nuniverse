class Tag < ActiveRecord::Base
	has_many :connections, :as => :subject, :class_name => "Polyco"
	
	alias_attribute :name, :label
	
	def self.find_or_create(params)
		Tag.find(:first, :conditions => {:label => params[:name]}) || Tag.create(:label => params[:name]) 
	end
	
	def avatar
		return nil
	end
	
	def tags
		[]
	end

end

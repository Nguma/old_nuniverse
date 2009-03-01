class Tag < ActiveRecord::Base
	
	has_many :connections_as_object, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :connections_as_subject, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :properties, :through => :connections_as_object, :source => :subject, :source_type => "Tag"
	
	has_many :taggings, :as => :tag, :class_name => "Tagging"
	has_many :nuniverses, :through => :taggings, :source => :taggable, :source_type => "Nuniverse"
	
	define_index do 
		indexes :name
	end
	
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

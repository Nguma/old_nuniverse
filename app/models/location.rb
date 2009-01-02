class Location < ActiveRecord::Base
	has_many :taggings, :as => :taggable
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"

	
	def find_telephone_numbers
		nuniverses.search :conditions => {:predicate => "tel|telephone"}, :match_mode => :boolean
	end
end
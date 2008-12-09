class Nuniverse < ActiveRecord::Base
	has_many :taggings, :as => :taggable
	has_many :connections_from, :as => :subject, :class_name => "Connection"
	has_many :connections_to, :as => :object,  :class_name => "Connection"
		
		
	alias_attribute :label, :name
		
	def kind
		"nuniverse"
	end
	
	def tags
		taggings.collect {|c| c.predicate}
	end
	
	def thumbnail
		connections_from.with_object_type('Image').first
	end
	
	def url
		
	end
	
	def description
		
	end
end
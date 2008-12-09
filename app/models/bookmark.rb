class Bookmark < ActiveRecord::Base
	has_many :taggings, :as => :taggable
	
	alias_attribute :label, :name
	
	def kind
		"bookmark"
	end
	
	def thumbnail
		nil
	end
	
	def tags
		taggings.collect {|c| c.predicate}
	end
	
	def description
		"bleh"
	end
end
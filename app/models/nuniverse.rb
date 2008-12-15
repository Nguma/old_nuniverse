class Nuniverse < ActiveRecord::Base
	has_many :taggings, :as => :taggable
	has_many :polycos
		
	alias_attribute :label, :name

end
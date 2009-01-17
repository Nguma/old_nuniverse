class Location < ActiveRecord::Base
	has_many :taggings, :as => :taggable
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"

	
	named_scope :gather, lambda {|nuniverses|
			nuniverses.nil? ? {} : {:joins => ["LEFT OUTER JOIN polycos P on P.subject_id = locations.id AND P.subject_type = 'Location'"], :conditions => ["P.object_id IN (?) AND P.object_type = 'Nuniverse'", nuniverses]}
		
		}
		
	def find_telephone_numbers
		nuniverses.search :conditions => {:predicate => "tel|telephone"}, :match_mode => :boolean
	end
	
	def lat
		latlng.split(',')[0]
	end
	
	def lng
		latlng.split(',')[1]
	end
	
	def address
		full_address
	end
end
class Collection < ActiveRecord::Base
		# 
		# belongs_to :parent, :polymorphic => true
		# 
		# has_many :taggings_as_taggable, :as => :taggable, :class_name => :taggings
		# has_many :tags, :through => :taggings_as_taggable, :source => :tag, :source_type => "Tag"
		# has_many :taggings_as_tag, :as => :tag, :class_name => :taggings, :dependent => :destroy
		# 
		# has_many :children, :through => :taggings_as_tag, :class_name => :taggable, :source_type => "Nuniverse"
		# 
		# has_many :connections, :as => :object, :class_name => "Polyco", :dependent => :destroy
		# 
		# 
		# has_many :prop_connections, :as => :object, :class_name => "Polyco", :dependent => :destroy, :conditions => {:subject_type => "Tag"}
		# has_many :properties, :through => :connections, :source => :subject, :source_type => "Tag"
		# 
		# 
		# 
		# define_index do 
		# 	indexes :name
		# end
		# 
		# 
		# 
		# def ontology
		# 	XMLObject.new(self.description)
		# end
		# 
		# 
		# 
		# def set_properties(props)
		# 	
		# 	d = "<properties>"
		# 	tags = []
		# 	props.each do |p|
		# 		unless p.blank?
		# 			
		# 			t = Tag.find_or_create(:name => p)
		# 			tags << t
		# 			d << "<property id='#{t.id}'/>"
		# 		end
		# 	end
		# 
		# 	d << "</properties>"
		# 	self.description = description 
		# 
		# 	self.properties = tags
		# 	
		# 	# 6.times do |time|
		# 	# 		c = prop_connections[time]
		# 	# 		t = tags[time]
		# 	# 		
		# 	# 		
		# 	# 		if c && t
		# 	# 			c.subject = t
		# 	# 			c.save
		# 	# 		elsif c
		# 	# 			c.destroy
		# 	# 		elsif t
		# 	# 			self.properties << t
		# 	# 		end
		# 	# 			
		# 	# 		
		# 	# 	end
		# 
		# 	
		# end
	
	
end

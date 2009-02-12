class Group < ActiveRecord::Base
	belongs_to :source, :class_name => "Story", :foreign_key => "parent_id"
	
	has_many :connections, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :prop_connections, :as => :object, :class_name => "Polyco", :dependent => :destroy, :conditions => {:subject_type => "Tag"}
	has_many :properties, :through => :connections, :source => :subject, :source_type => "Tag"
	
	def ontology
		XMLObject.new(self.description)
	end
	

	
	def set_properties(props)
		
		d = "<properties>"
		tags = []
		props.each do |p|
			unless p.blank?
				
				t = Tag.find_or_create(:name => p)
				tags << t
				d << "<property id='#{t.id}'/>"
			end
		end
	
		d << "</properties>"
		self.description = description 
		
		
		6.times do |time|
			c = prop_connections[time]
			t = tags[time]
			
			
			if c && t
				c.subject = t
				c.save
			elsif c
				c.destroy
			elsif t
				self.properties << t
			end
				
			
		end

		
	end
	
	
end

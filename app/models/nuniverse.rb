class Nuniverse < ActiveRecord::Base
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"
	has_many :contexts, :through => :taggings, :source => :tag, :source_type => "Story"	
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :connecteds, :as => :subject, :class_name => "Polyco"
	
	has_many :parents, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :locations, :through => :connections, :source => :subject, :source_type => "Location"
	has_many :stories, :through => :connections, :source => :subject, :source_type => "Story"
	# has_many :contexts, :through =>:connecteds, :source => :object, :source_type => "Story"

	has_many :users, :through => :connecteds, :source => :object, :source_type => "User"
	has_many :facts, :through => :connecteds, :source => :object, :source_type => "Fact"
	
	
	
	define_index do
    indexes :name, :as => :name,  :sortable => true
		# indexes description
		indexes [taggings(:tag).name, connecteds(:object).name], :as => :tags
	
		has :active
		has connections(:id), :as => :c_id
		has tags(:id), :as => :tag_ids
		has contexts(:id), :as => :context_ids
		
		set_property :delta => true
		set_property :field_weights => {:name => 100}
	end
	


	def avatar(size = {})
		connections.of_klass('Image').with_score.order_by_score.first.subject.public_filename(size) rescue nil
	end
	
	def categories
		connections.gather_tags
	end
	
	

	
end
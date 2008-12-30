class Nuniverse < ActiveRecord::Base
	has_many :taggings, :as => :taggable, :dependent => :destroy
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	
	define_index do
    indexes name, :sortable => true
		# indexes description
		# indexes taggings(:predicate), :as => :predicate
		
		has :active
		has connections(:id), :as => :c_id
		set_property :delta => true
	end
	
	def tags
		taggings.collect {|c| c.predicate}
	end

	def avatar(size = {})
		connections.of_klass('Image').with_score.order_by_score.first.subject.public_filename(size) rescue nil
	end
	
end
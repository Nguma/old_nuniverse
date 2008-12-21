class Bookmark < ActiveRecord::Base
	has_many :taggings, :as => :taggable
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	
	before_create :make_name
	
	
	def tags
		taggings.collect {|c| c.predicate}
	end

	def avatar(size = {})
		connections.of_klass('Image').with_score.order_by_score.first.subject.public_filename(size)
	end
	
	protected
	
	def make_name
		self.name ||= self.url
	end
end
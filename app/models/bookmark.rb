class Bookmark < ActiveRecord::Base
	has_many :taggings_as_taggable, :as => :taggable, :class_name => :taggings
	has_many :tags, :through => :taggings_as_taggable, :source => :tag, :source_type => "Tag"
	has_many :taggings_as_tag, :as => :tag, :class_name => :taggings, :dependent => :destroy
	
	has_many :connections, :as => :object, :class_name => "Polyco"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	
	# before_create :make_name
	
	def category
		tags.first.name rescue nil
	end
	
	def tags
		taggings.collect {|c| c.predicate}
	end

	def avatar(size = {})
		connections.of_klass('Image').with_score.order_by_score.first.subject.public_filename(size)
	end
	

	
	protected
	
	def self.find_or_create(params)
		b = Bookmark.find_by_url(params[:url])
		b = Bookmark.create(:url => params[:url], :name => params[:url]) if b.nil?
		b
	end
	
	def make_name
		self.name ||= self.url
	end
end
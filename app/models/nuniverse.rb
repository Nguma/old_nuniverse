class Nuniverse < ActiveRecord::Base
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :tags, :through => :taggings, :source => :tag, :source_type => "Tag"
	has_many :contexts, :through => :taggings, :source => :tag, :source_type => "Collection"	
	
	has_many :connections, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :connecteds, :as => :subject, :class_name => "Polyco", :dependent => :destroy
	
	has_many :story_connections, :as => :subject, :class_name => "Polyco", :dependent => :destroy
	
	belongs_to :redirect, :class_name => "Nuniverse"
	
	has_many :parents, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :locations, :through => :connections, :source => :subject, :source_type => "Location"
	has_many :bookmarks, :through => :connections, :source => :subject, :source_type => "Bookmark"
	has_many :comments, :through => :connections, :source => :subject, :source_type => "Comment"
	has_many :facts,:through => :connections, :source => :subject, :source_type => "Fact"
	
	has_many :stories, :through => :connecteds, :source => :object, :source_type => "Story"
	has_many :videos, :through => :connecteds, :source => :object, :source_type => "Video"
	has_many :users, :through => :connecteds, :source => :object, :source_type => "User"
	# has_many :facts, :through => :connections, :source => :subject, :source_type => "Fact"
	has_many :collections, :foreign_key => :parent_id	
	

	has_many :boxes, :as => :parent
	
	
	has_many :aliases, :foreign_key => :redirect_id, :class_name => 'Nuniverse'
	
	has_many :votes, :as => :rankable, :class_name => 'Ranking'
	
	
	define_index do
    indexes :name, :as => :name,  :sortable => true
		indexes :unique_name, :as => :identifier, :sortable => true
		indexes [taggings(:tag).name], :as => :tags
		indexes [polycos(:object).name, taggings(:tag).name], :as => :contexts
		# indexes [:name, taggings(:tag).name, connecteds(:object).name], :as => :tags
	
		has :active
		# has connections(:id), :as => :c_id
		has tags(:id), :as => :tag_ids
		has contexts(:id), :as => :context_ids
		has "CHAR_LENGTH(nuniverses.name)", :as => :length, :type => :integer
		
		set_property :delta => true
		set_property :field_weights => {:name => 100}
		set_property :enable_star => true
		set_property :min_prefix_len => 1

	  
	end
	



	def avatar(size = {})
		connections.of_klass('Image').with_score.order_by_score.first.subject rescue nil
	end
	
	def categories
		Tag.search(:conditions => {:object_id => self.id, :object_type => 'Nuniverse' }, :per_page => 10)
	end
	

	def related_connections
		Polyco.related_connections(self)
	end
	
	def property(tag)
		self.connections.tagged(tag).to_a.first
	end
	
	def set_property(tag, value)
		begin 
			p = property(tag).subject 
		rescue 
			p = Fact.new
			self.facts << p
		end
		p.body = value
		p.tags << tag rescue nil
		p.save
	end
	
	def rank
		
	end
	
	def stat(params)
		return Stat.new(:score => params[:score], :value => votes.count(:conditions  => ['score = ?', params[:score]]), :total => votes.count)
	end
	
	def score
		(votes.average(:score)) rescue nil
	end
	
	protected
	def self.find_or_create(params)

			# params[:path].split('/').reject {|p| p.blank?}
			

			params[:uid] = params[:unique_name] || params[:name]
			params[:uid] = Token.sanatize(params[:uid])
			params[:name] = params[:name] || params[:uid]
			params[:name] = Token.humanize(params[:name]).gsub('/','')
			params[:is_unique] ||= 0
			# n = Nuniverse.search(:conditions => {:tags => params[:path]}).first
			
			# if n.nil?
			
				n = Nuniverse.find(:first, :conditions => ["unique_name = ?",params[:uid]])
				n = Nuniverse.create(:unique_name => params[:uid], :name => params[:name], :is_unique => params[:is_unique], :active => 1) if n.nil?
				n.tags << Tag.find_or_create(:name => params[:path]) rescue nil
			
			# end
			n

	end

	
end
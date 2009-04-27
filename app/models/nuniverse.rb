class Nuniverse < ActiveRecord::Base
	has_many :taggings, :as => :taggable, :dependent => :destroy
	has_many :rankings, :as => :rankable, :dependent => :destroy
	
	has_many :tags, :through => :taggings

	has_many :platforms, :through => :taggings, :source => :tag, :conditions => "tags.parent_id = '5757'"
	has_many :dates, :through => :taggings, :source => :tag, :conditions => "(tags.parent_id IS NOT NULL and tags.parent_id = 5391) "
	has_many :genres, :through => :taggings, :source => :tag,  :conditions => "tags.parent_id IS NULL"		

	has_many :kinds, :through => :taggings, :source => :tag, :source_type => "Tag", :conditions => "tags.parent_id = 5561"

	
	has_many :connections, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :connecteds, :as => :subject, :class_name => "Polyco", :dependent => :destroy
	
	belongs_to :redirect, :class_name => "Nuniverse"
	
	has_many :redirecteds, :class_name => "Nuniverse", :foreign_key => "redirect_id"
	
	has_many :parents, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	has_many :images, :through => :connections, :source => :subject, :source_type => "Image"
	has_many :nuniverses, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	has_many :locations, :through => :connections, :source => :subject, :source_type => "Location"
	has_many :bookmarks, :through => :connections, :source => :subject, :source_type => "Bookmark"
	has_many :comments, :through => :connections, :source => :subject, :source_type => "Comment"
	has_many :facts,:through => :connections, :source => :subject, :source_type => "Fact"
	has_many :videos, :through => :connecteds, :source => :object, :source_type => "Video"
	has_many :users, :through => :connecteds, :source => :object, :source_type => "User"
	
	has_many :connected_nuniverses, :through => :connecteds, :source => :object, :source_type => "Nuniverse"
	

	
	has_many :boxes, :as => :parent
	has_many :aliases, :foreign_key => :redirect_id, :class_name => 'Nuniverse'
	
	
	# named_scope :with_rankings, :select => "nuniverses.*, AVG(rankings.score) as score", :joins => ["LEFT OUTER JOIN rankings on rankable_id = nuniverses.id AND rankable_type = 'Nuniverse'"], :group => "nuniverses.id"
	
	
	named_scope :sphinx, lambda {|*args| {
    :conditions => { :id => search_for_ids(*args) }
  }}

	define_index do
    indexes [:name, redirecteds.name], :as => :name,  :sortable => true
		indexes :unique_name, :as => :identifier, :sortable => true
	
		indexes tags(:name), :as => :tags
		indexes platforms.name, :as => :platforms
		indexes genres.name, :as => :genres
		
		# indexes dates.name, :as => :dates
		indexes rankings.score, :as => :score
		
		has "AVG(rankings.score)", :as => :score, :type => :integer
	
		
		# has :active
		# has dates(:name), :as => :dates, :type => :integer
		has tags(:id), :as => :tag_ids
		
		# has type_tags(:id), :as => :type_ids
		has users(:id), :as => :user_ids
		
		# has (:id), :as => :self_id

		has "CHAR_LENGTH(nuniverses.name)", :as => :length, :type => :integer
		
		set_property :delta => true
		where "nuniverses.redirect_id IS NULL"
	end
	
	def gather_tags 
		Tag.search(:conditions => {:subject_id => self.id, :subject_type => 'Nuniverse'})
	end

	def avatar(size = {})
		connections.of_klass('Image').with_score.order_by_score.first.subject rescue nil
	end
	
	def has_kinds?(kind)
		return true if taggings.find(:first, :conditions => ["tags.name = ?",kind], :include => :tag)
		return false
	end
	
	
	def pros
		connections.of_klass('Tag').with_score_higher_than(0)
	end
	
	def cons
		connections.of_klass('Tag').with_score_lower_than(0)
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
	
	def stats
		return [] if rankings.empty?
		rankings_by_score = rankings.group_by(&:score)
		stats = []
		11.times do |t|
			rankings_by_score[t] =  rankings_by_score[t] ? rankings_by_score[t] : [] 
		end
		rankings_by_score.collect {|s,v| {'score' => s.round,'count' => v.length, 'percent' => (v.length * 100)/rankings.count} }
	end
	
	def stat(params)
		return Stat.new(:score => params[:score], :value => rankings.count(:conditions  => ['score = ?', params[:score]]), :total => rankings.count)
	end
	
	def score
		(rankings.average(:score)) rescue 0
	end
	
	def total_score
		(rankings.sum(:score)) rescue 0
	end
	
	def percent_score
		((rankings.sum(:score) * 100) / (rankings.count * 5)) rescue nil
	end
	
	def to_json
		{
			:id => id,
			:name => name.titleize,
			:unique_name => unique_name,
			:image => (avatar.public_filename(:small) rescue nil),
			:tags => tags.collect {|t| t.name.capitalize}.join(', '),
			:score => score,
			:wdyto_uri => "/wdyto/#{unique_name}"
		}
	end
	
	def add(element, params = {})
		connection = Polyco.find_or_create(:object => self, :subject => element)
		begin
			connection.tags << params[:tags].collect {|t| Tag.find_or_create(:name => t)} if params[:tags]
		rescue 
		end
	end
	
	protected
	def self.find_or_create(params)
		params[:uid] = params[:unique_name] || params[:name]
		params[:uid] = Token.sanatize(params[:uid])
		params[:name] = params[:name] || params[:uid]
		params[:name] = Token.humanize(params[:name]).gsub('/','')
		params[:wikipedia_id] ||= nil
		params[:is_unique] ||= 0			
		n = Nuniverse.find(:first, :conditions => ["unique_name = ?",params[:uid]])
		n = Nuniverse.create(:unique_name => params[:uid], :name => params[:name], :is_unique => params[:is_unique], :active => 1, :wikipedia_id => params[:wikipedia_id]) if n.nil?
		n
	end

	
end
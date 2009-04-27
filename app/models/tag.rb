class Tag < ActiveRecord::Base
	
	
	has_many :connections_as_object, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :connections_as_subject, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :properties, :through => :connections_as_object, :source => :subject, :source_type => "Tag"
	
	has_many :taggings, :as => :tag, :class_name => "Tagging"
	has_many :nuniverses, :through => :taggings, :source => :taggable, :source_type => "Nuniverse"
	has_many :polycos, :through => :taggings, :source => :taggable, :source_type => "Polyco"
	
	belongs_to :redirect, :class_name => 'Tag'
	belongs_to :parent, :class_name => 'Tag'

	
	named_scope :sphinx, lambda {|*args| {
    :conditions => { :id => search_for_ids(*args) }
  }}
	
	define_index do 
		indexes :name, :sortable => true
		
		# indexes [nuniverses(:unique_name)], :as => :nuniverses
		# indexes [polycos.subject_type], :as => :subject_type
		# indexes [polycos.object_type], :as => :object_type

		# has nuniverses.tags(:id), :as => :related_tag_ids
		# has nuniverses(:id), :as => :tagged_nuniverse_ids
		# has nuniverses.users(:id), :as => :related_user_ids
		# has polycos(:object_id), :as => :object_id
		# has polycos(:subject_id), :as => :subject_id
		
		has (:id), :as => :self_id
		has (:parent_id), :as => :group_id
		
		set_property :delta => true
	end
		
	def avatar
		return nil
	end
	
	def tags
		[]
	end

	def unique_name
		name.gsub(' ', '_')
	end
	
	protected
	
	def self.analyze(str)
		
		Tag.find_or_create(:name => str)
	end
	
	def self.find_or_create(params)
		return if params[:name].blank?
		t = Tag.find(:first, :conditions => {:name => params[:name]}) 
		return Tag.create(:name => params[:name].capitalize) if t.nil?
		return t.redirect if t.redirect	
		t
	end
end

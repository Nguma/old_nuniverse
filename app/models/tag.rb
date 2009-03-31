class Tag < ActiveRecord::Base
	
	has_many :connections_as_object, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :connections_as_subject, :as => :object, :class_name => "Polyco", :dependent => :destroy
	has_many :properties, :through => :connections_as_object, :source => :subject, :source_type => "Tag"
	
	has_many :taggings, :as => :tag, :class_name => "Tagging"
	has_many :nuniverses, :through => :taggings, :source => :taggable, :source_type => "Nuniverse"
	has_many :polycos, :through => :taggings, :source => :taggable, :source_type => "Polyco"

	
	define_index do 
		indexes :name, :sortable => true
		# indexes [nuniverses(:unique_name)], :as => :nuniverses
		indexes [polycos.subject_type], :as => :subject_type
		indexes [polycos.object_type], :as => :object_type

		
		has nuniverses(:id), :as => :tagged_nuniverse_ids
		has nuniverses.users(:id), :as => :related_user_ids
		has polycos(:object_id), :as => :object_id
		has polycos(:subject_id), :as => :object_id
		
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
		Tag.find(:first, :conditions => {:name => params[:name]}) || Tag.create(:name => params[:name].capitalize) 
	end
end

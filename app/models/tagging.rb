class Tagging < ActiveRecord::Base
	belongs_to :taggable, :polymorphic => true 
	belongs_to :tag, :polymorphic => true
	
	
	define_index do
		# indexes tag.name, :as => :predicate
		indexes tag.name, :as => :predicate
		set_property :delta => true
	end
	# has_many :rankings

	cattr_reader :per_page 
  @@per_page = 5

	
	def predicate
		tag.name
	end
	
	protected
	

	private

end

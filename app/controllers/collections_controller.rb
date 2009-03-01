class CollectionsController < ApplicationController
	
	before_filter :find_context, :only => [:index]
	
	def index
		
		@collections = @context.collections.paginate(:page => 1, :per_page => 20) 
	end
	
	def show
		@collection = Collection.find(params[:id])
		@context = @collection.parent
		
		@connections = @context.connections.of_klass('Nuniverse').tagged(@collection).paginate(:page => params[:page], :per_page => 30)
		@mode = params[:mode] || "list"
	end
	
	def create
		@collection = Collection.create(params[:collection])	
		@collection.parent_id = params[:source][:id]
		@collection.unique_name = sanatize(@collection.name)
		@object = params[:source][:type].classify.constantize.find(params[:source][:id]) rescue nil
		@object.collections << @collection if @object
		@tags = params[:tags].split(',').collect {|c| Tag.find_or_create(:name => c)}

		# @collection.tags = @tags
		
		# Finds matching Tag for each property, 
		# adds them to a property array, then
		# replaces the @set.properties with that array
		# Also adds an xml version in the description for taking care of display ordering. #TODO!!
		@collection.set_properties(params[:properties])
		
		@collection.save
		
		respond_to do |f|
			f.html {}
			f.js { render :action => :show}
		end
	
	end
end
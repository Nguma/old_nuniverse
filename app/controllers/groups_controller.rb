class GroupsController < ApplicationController
	
	before_filter :find_group, :except => [:create, :update, :new]
	before_filter :find_source, :only => [:new]
	
	def show
		@mode = params[:mode] || ""
		@elements = @group.nuniverses
		@collection_1 = @elements.collect {|c| c.subject.property(@group.properties.second) rescue nil }

		respond_to do |f|
			f.js {}	
		end
	end
	
	def create
		@set = Group.create(params[:group])	
		@set.parent_id = params[:source]['id']
		@set.unique_name = Nuniversal.sanatize(@set.name)
		
		# Finds matching Tag for each property, 
		# adds them to a property array, then
		# replaces the @set.properties with that array
		# Also adds an xml version in the description for taking care of display ordering. #TODO!!
		@set.set_properties(params[:properties])
		@set.save
	
	end
	
	
	def add_item
		if params[:nuniverse]
			@nuniverse = Nuniverse.find(params[:nuniverse])
			@properties = [] 
			@group.properties.each do |p|
			
				@properties << Property.new(:label => p.name, :value => (@nuniverse.property(p).subject.body rescue nil))
			end
		else
			@nuniverse = Nuniverse.new
			@properties = @group.properties.collect {|c| Property.new(:label => c.name, :value => nil)}
		end
		
		
		
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end
	
	def new
	end
	
	
	def edit
		
	end
	
	def update
	
		@group = Group.find(params[:group][:id]) rescue Group.find(params[:id])
		@group.set_properties(params[:properties]) if params[:properties]
		
		respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'This set was successfully updated.'
        format.html { redirect_to(@group) }
				format.js { 
					@elements = @group.nuniverses
				
				}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
	end
	

	
	protected 
	
	def find_group
		@group = Group.find(params[:id])
	end
	
end

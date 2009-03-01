class GroupsController < ApplicationController
	
	before_filter :find_group, :except => [:create, :update, :new]
	before_filter :find_source, :only => [:new]
	
	def show
		@mode = session[:mode] = params[:mode] || "list"
		@connections = @group.parent.connections.of_klass('Nuniverse').tagged(@group).paginate(:page => params[:page], :per_page => 15)
		# @collection = @elements.collect {|c| c.subject.property(@group.properties.first).subject.body rescue nil }
		# @highest_value = @collection.sort {|x,y| x <=> y }.first.gsub(/[^0-9\.]/,'')
		@source = @group
		respond_to do |f|
			f.html {}
			f.js {}	
		end
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
		
		@mode = session[:mode]
		respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'This set was successfully updated.'
        format.html { redirect_to(@group) }
				format.js { 
					@elements = @group.connections.of_klass('Nuniverse').paginate(:page => 1, :per_page => 12)
				
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

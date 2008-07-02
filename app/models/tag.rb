class Tag < ActiveRecord::Base
  has_one :avatar
	
	validates_presence_of :content, :kind
	
	attr_accessor :crumbs
		
	def move(original_path, new_path)
	  Tagging.transaction do
      Tagging.switch_paths("#{original_path}_id", "#{new_path}_id")
    
      Tagging.find(:first, :conditions => {
        :subject_id => original_path.split('_').last,
        :object_id  => self.id,
        :user_id    => self.user_id,
        :path       => original_path
      }).update_attributes(
        :subject_id => new_path.split('_').last,
        :path       => new_path
      )
    end
  end
	
	def self.connect(params)
		@object = Tag.find_by_content_and_kind(params[:content], params[:kind])
		@object ||= Tag.create(:content => params[:content], :kind => params[:kind])
		
		unless params[:user_id].nil?
			@subject = Tag.find(params[:path].split('_').last)
			@tagging = Tagging.create(
				:subject 	=> @subject,
				:object 	=> @object,
				:path    	=> "_#{params[:path]}_",
				:user_id	=> params[:user_id]
			)
		end
		
		@tagging
	end
	
	def self.find_taggeds_with(params)
		
		@context = params[:context].collect {|s| s.id}.join('_')
		# @subjects = params[:subjects].collect {|s| s.id}.join(',')
		# @objects = params[:objects].collect {|o| o.id}.join(',') if params[:objects]
		if params[:reverse]
			oid = "subject_id"
			sid = "object_id"
			
		else
			oid = "object_id"
			sid = "subject_id"
		end
		
		sub_query = "SELECT #{oid} FROM taggings WHERE path rlike '_#{@context}_'"
		sub_query << " AND #{sid} in (#{@subjects}) " if @subjects
		sub_query << " AND #{oid} in (#{@objects}) " if @objects
		sub_query << " AND user_id in (#{params[:user_id]})" if params[:user_id]
		sub_query << " GROUP BY #{oid} HAVING count(#{oid}) >= 1 ORDER BY path ASC"
		query = "SELECT tags.* FROM tags WHERE tags.id in (#{sub_query})"
		query << " AND kind = '#{params[:kind]}'" if params[:kind]
		query << " ORDER BY content DESC"
		
		Tag.find_by_sql(query)
	end
  
  protected
  
  def self.switch_paths(original_path, new_path)
    Tagging.execute <<-SQL
    UPDATE taggings
    SET path = '#{new_path}' + SUBSTRING(path, CHAR_LENGTH('#{original_path}') + 1)
    WHERE path REGEXP '^#{original_path}'
    SQL
  end
end

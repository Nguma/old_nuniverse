class Tag < ActiveRecord::Base
  has_one :avatar
  	
	validates_presence_of :content, :kind
	
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
  
  protected
  
  def self.switch_paths(original_path, new_path)
    Tagging.execute <<-SQL
    UPDATE taggings
    SET path = '#{new_path}' + SUBSTRING(path, CHAR_LENGTH('#{original_path}') + 1)
    WHERE path REGEXP '^#{original_path}'
    SQL
  end
end

class FreebaseMapping < ActiveRecord::Base
  validates_presence_of :freebase_type, :local_type
  
  def self.local_type_for(freebase_type)
    mapping = FreebaseMapping.find(:first, :conditions => {:freebase_type => freebase_type})
    mapping.nil? ? nil : mapping.local_type
  end
  
  def self.freebase_type_for(local_type)
    mapping = FreebaseMapping.find(:first, :conditions => {:local_type => local_type})
    mapping.nil? ? nil : mapping.freebase_type
  end
end

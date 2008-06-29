class Avatar < ActiveRecord::Base
  belongs_to :tag
  
  has_attachment :content_type => :image,
    :thumbnails => {
      :small => [ 50,  50],
      :large => [100, 100]
    },
    :processor  => :image_science,
    :storage    => :file_system
  
  validates_as_attachment
end

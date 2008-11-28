class Audio < ActiveRecord::Base
	has_attachment    :content_type => 'application/mp3',
										:path_prefix => "public/attachments",
										:storage => :file_system,
	                  :max_size => 10.megabytes,
	                  :processor => :none
	                   
	validates_as_attachment
end
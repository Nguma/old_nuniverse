class Image < ActiveRecord::Base
  belongs_to :tag

	before_create :create_tag
  
  has_attachment	:content_type => :image,
    							:thumbnails => {
      							:small => '80x80!',
      							:large => '150x150!',
										:box => '400x80!'
    							},
    							:processor  => :image_science,
									:path_prefix => "public/attachments",
									:partition => true,
									:max_size => 8.megabytes,
    							:storage    => :file_system

  
  validates_as_attachment

	#override from has_attachment plugin
  def uploaded_data=(file_data)
    return nil if file_data.nil? || file_data.size == 0
    self.filename = file_data.original_filename if respond_to?(:filename)
    if file_data.is_a?(StringIO)
      file_data.rewind
      self.temp_data = file_data.read
    else
      self.temp_path    = file_data.path
    end
    # in the original the next line occured earlier, and just used file_data.content_type
    self.content_type = get_content_type((file_data.content_type.chomp if file_data.content_type))
  end

  #uses the os's "file" utility to determine the file type, yanked and modified slightly from file_column.
  def get_content_type(fallback=nil)
      begin
        content_type = `file -bi "#{File.join(temp_path)}"`.chomp
        content_type = fallback unless $?.success?
        content_type.gsub!(/;.+$/,"") if content_type
        content_type
      rescue
        fallback
      end
  end
  
  # def full_filename(thumbnail = nil)
  #     file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
  #     File.join(RAILS_ROOT, file_system_path, thumbnail_name_for(thumbnail))
  # end

	def source_url=(url)
	  return nil if not url
	  http_getter = Net::HTTP
	  uri = URI.parse(url)
	  response = http_getter.start(uri.host, uri.port) {|http|
	    http.get(uri.path)
	  }
	  case response
	  when Net::HTTPSuccess
	    file_data = response.body
	    return nil if file_data.nil? || file_data.size == 0
	    self.content_type = response.content_type
	   	self.temp_data = file_data
	
	    self.filename = uri.path.split('/')[-1]
	else
	    return nil
	  end
	end
	
	def create_tag
		if self.parent_id.nil?
			t = Tag.create!(
				:label => self.filename,
				:kind => 'image'
			)
			self.tag = t
		end
	end

end
class TaggingPath
  attr_reader :ids
  
  def initialize(path = "")
		case path
		when Array
			parse_array path
		when Integer
			@ids = [path]
		else
    	parse(path || "")
		end
  end
  
  def to_s
    "_#{@ids.join('_')}_"
  end
  
  def first
    @ids.first
  end
  
  def last
    @ids.last
  end
	
	def last_tagging
		self.taggings.last
	end
	
	def last_tag
		@last_tag ||= Tag.find self.taggings.last.object
	end
  
  def tags
    @tags ||= self.taggings.collect { |tagging| Tag.find tagging.object.id }
  end
  
  def empty?
    @ids.empty?
  end
	
	def path_for(tag)
		tag = case tag
		when Tag
			tag.id
		else
			tag
		end
		
		"_#{@ids[0..@ids.index(tag)].join("_")}_"
	end
	
	def taggings
		# @taggings ||= @ids.collect { |id|
		# 			TaggingPath.new(@ids[0..@ids.index(id)])
		# 		}
		@taggings ||= @ids.collect { |id| Tagging.find id }
	end
	
	def parent
	  @parent ||= TaggingPath.new @ids[0..-2]
  end
  
  def restricted?
    self.taggings.any? { |tagging| tagging.restricted }
  end
  
  private
  
  def parse(path)
    @ids = path.to_s.split('_').select { |id|
      !id.blank?
    }.collect { |id|
      id.to_i
    }
  end
  
  def parse_array(arr)
    @ids = arr.collect { |tag|
			case tag
			when Tagging
				tag.id
			else
				tag
			end
		}
  end
end
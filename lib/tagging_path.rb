class TaggingPath
  attr_reader :ids
  
  def initialize(path)
    parse(path || "")
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
  
  def tags
    @tags ||= @ids.collect { |id| Tag.find id }
  end
  
  private
  
  def parse(path)
    @ids = path.to_s.split('_').select { |id|
      !id.blank?
    }.collect { |id|
      id.to_i
    }
  end
end
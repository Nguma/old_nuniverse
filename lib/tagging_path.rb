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
  
  private
  
  def parse(path)
    @ids = path.split('_').select { |id| !id.blank? }.collect { |id| id.to_i }
  end
end
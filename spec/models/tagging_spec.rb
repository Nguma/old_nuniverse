require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tagging do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Tagging.create!(@valid_attributes)
  end
  
  it "should return a TaggingPath instance for path" do
    Tagging.new(:path => "_1_2_").path.should be_kind_of(TaggingPath)
  end
  
  it "should accept TaggingPaths or Strings for path" do
    tagging = Tagging.new(:path => "_1_2_")
    tagging.path = "_1_3_4_"
    tagging.path.to_s.should == "_1_3_4_"
    tagging.path = TaggingPath.new("_1_4_3_")
    tagging.path.to_s.should == "_1_4_3_"
  end
end

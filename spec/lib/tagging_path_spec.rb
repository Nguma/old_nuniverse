require 'spec/spec_helper'

describe TaggingPath do
  before :each do
    @path = "_1_2_3_4_"
  end
  
  it "should parse a string of ids" do
    TaggingPath.new(@path).ids.should == [1, 2, 3, 4]
  end
  
  it "should return the first item" do
    TaggingPath.new(@path).first.should == 1
  end
  
  it "should return the last item" do
    TaggingPath.new(@path).last.should == 4
  end
  
  it "should build the path string" do
    TaggingPath.new(@path).to_s.should == @path
  end
end
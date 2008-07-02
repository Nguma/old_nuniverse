require 'spec/spec_helper'

describe TaggingPath do
  before :each do
    @path = "_1_2_3_4_"
    
    Tag.stub_method(:find => Tag.stub_instance)
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
  
  it "should handle integers" do
    lambda { TaggingPath.new(42) }.should_not raise_error
  end
  
  it "should return an array of Tags" do
    TaggingPath.new(@path).tags.each { |tag|
      tag.should be_kind_of(Tag)
    }
  end
	
	it "should return a Tag for last_tag" do
		tagging = TaggingPath.new(@path)
		tagging.last_tag.should be_kind_of(Tag)
		
		Tag.should have_received(:find).with(tagging.last)
	end
  
  it "should be empty if no ids" do
    TaggingPath.new.should be_empty
  end
  
  it "should not be empty if there are some ids" do
    TaggingPath.new(@path).should_not be_empty
  end
end
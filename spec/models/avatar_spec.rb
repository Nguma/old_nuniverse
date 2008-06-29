require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Avatar do
  it "should belong to a tag" do
    Avatar.should belong_to(:tag)
  end
end

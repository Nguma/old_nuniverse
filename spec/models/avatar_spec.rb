require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Image do
  it "should belong to a tag" do
    Image.should belong_to(:tag)
  end
end

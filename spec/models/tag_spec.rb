require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tag do
  before(:each) do
    @attributes = {
      #
    }
  end

  it "should have one avatar" do
    Tag.should have_one(:avatar)
  end
end

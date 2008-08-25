require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/lists/show.html.erb" do
  include ListsHelper
  
  before(:each) do
    assigns[:list] = @list = stub_model(List)
  end

  it "should render attributes in <p>" do
    render "/lists/show.html.erb"
  end
end


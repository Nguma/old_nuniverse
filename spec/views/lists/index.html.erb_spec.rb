require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/lists/index.html.erb" do
  include ListsHelper
  
  before(:each) do
    assigns[:lists] = [
      stub_model(List),
      stub_model(List)
    ]
  end

  it "should render list of lists" do
    render "/lists/index.html.erb"
  end
end


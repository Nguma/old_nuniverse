require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ListsController do
  describe "route generation" do

    it "should map { :controller => 'lists', :action => 'index' } to /lists" do
      route_for(:controller => "lists", :action => "index").should == "/lists"
    end
  
    it "should map { :controller => 'lists', :action => 'new' } to /lists/new" do
      route_for(:controller => "lists", :action => "new").should == "/lists/new"
    end
  
    it "should map { :controller => 'lists', :action => 'show', :id => 1 } to /lists/1" do
      route_for(:controller => "lists", :action => "show", :id => 1).should == "/lists/1"
    end
  
    it "should map { :controller => 'lists', :action => 'edit', :id => 1 } to /lists/1/edit" do
      route_for(:controller => "lists", :action => "edit", :id => 1).should == "/lists/1/edit"
    end
  
    it "should map { :controller => 'lists', :action => 'update', :id => 1} to /lists/1" do
      route_for(:controller => "lists", :action => "update", :id => 1).should == "/lists/1"
    end
  
    it "should map { :controller => 'lists', :action => 'destroy', :id => 1} to /lists/1" do
      route_for(:controller => "lists", :action => "destroy", :id => 1).should == "/lists/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'lists', action => 'index' } from GET /lists" do
      params_from(:get, "/lists").should == {:controller => "lists", :action => "index"}
    end
  
    it "should generate params { :controller => 'lists', action => 'new' } from GET /lists/new" do
      params_from(:get, "/lists/new").should == {:controller => "lists", :action => "new"}
    end
  
    it "should generate params { :controller => 'lists', action => 'create' } from POST /lists" do
      params_from(:post, "/lists").should == {:controller => "lists", :action => "create"}
    end
  
    it "should generate params { :controller => 'lists', action => 'show', id => '1' } from GET /lists/1" do
      params_from(:get, "/lists/1").should == {:controller => "lists", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'lists', action => 'edit', id => '1' } from GET /lists/1;edit" do
      params_from(:get, "/lists/1/edit").should == {:controller => "lists", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'lists', action => 'update', id => '1' } from PUT /lists/1" do
      params_from(:put, "/lists/1").should == {:controller => "lists", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'lists', action => 'destroy', id => '1' } from DELETE /lists/1" do
      params_from(:delete, "/lists/1").should == {:controller => "lists", :action => "destroy", :id => "1"}
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ListsController do
  describe "responding to GET /lists" do

    before(:each) do
      List.stub!(:find)
    end
  
    def do_get
      get :index
    end
  
    it "should succeed" do
      do_get
      response.should be_success
    end

    it "should render the 'index' template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all lists" do
      List.should_receive(:find).with(:all).and_return([@list])
      do_get
    end
  
    it "should assign the found lists for the view" do
      List.should_receive(:find).and_return([list = mock_model(List)] )
      do_get
      assigns[:lists].should == [list]
    end
  end

  describe "responding to GET /lists.xml" do

    before(:each) do
      List.stub!(:find)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should succeed" do
      do_get
      response.should be_success
    end

    it "should find all lists" do
      List.should_receive(:find).with(:all)
      do_get
    end
  
    it "should render the found lists as xml" do
      lists = mock("Array of Lists")
      List.should_receive(:find).and_return(lists)
      lists.should_receive(:to_xml).and_return("generated XML")
      do_get
      response.body.should == "generated XML"
    end
  end

  describe "responding to GET /lists/1" do

    before(:each) do
      List.stub!(:find)
    end
  
    def do_get(id="1")
      get :show, :id => id
    end

    it "should succeed" do
      do_get
      response.should be_success
    end
  
    it "should render the 'show' template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the list requested" do
      List.should_receive(:find).with("37")
      do_get("37")
    end
  
    it "should assign the found list for the view" do
      List.should_receive(:find).and_return(list = mock_model(List))
      do_get
      assigns[:list].should equal(list)
    end
  end

  describe "responding to GET /lists/1.xml" do

    before(:each) do
      List.stub!(:find)
    end
  
    def do_get(id="1")
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => id
    end

    it "should succeed" do
      do_get
      response.should be_success
    end
  
    it "should find the list requested" do
      List.should_receive(:find).with("37")
      do_get("37")
    end
  
    it "should render the found list as xml" do
      list = mock_model(List)
      List.should_receive(:find).and_return(list)
      list.should_receive(:to_xml).and_return("generated XML")
      do_get
      response.body.should == "generated XML"
    end
  end

  describe "responding to GET /lists/new" do

    def do_get
      get :new
    end

    it "should succeed" do
      do_get
      response.should be_success
    end
  
    it "should render the 'new' template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new list" do
      List.should_receive(:new)
      do_get
    end
  
    it "should not save the new list" do
      List.should_receive(:new).and_return(list = mock_model(List))
      list.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new list for the view" do
      List.should_receive(:new).and_return(list = mock_model(List))
      do_get
      assigns[:list].should equal(list)
    end
  end

  describe "responding to GET /lists/1/edit" do

    before(:each) do
      List.stub!(:find)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should succeed" do
      do_get
      response.should be_success
    end
  
    it "should render the 'edit' template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the list requested" do
      List.should_receive(:find)
      do_get
    end
  
    it "should assign the found List for the view" do
      List.should_receive(:find).and_return(list = mock_model(List))
      do_get
      assigns[:list].should equal(list)
    end
  end

  describe "responding to POST /lists" do

    before(:each) do
      @list = mock_model(List, :to_param => "1")
      List.stub!(:new).and_return(@list)
    end
    
    describe "with successful save" do
  
      def do_post
        @list.should_receive(:save).and_return(true)
        post :create, :list => {}
      end
  
      it "should create a new list" do
        List.should_receive(:new).with({}).and_return(@list)
        do_post
      end

      it "should assign the created list for the view" do
        do_post
        assigns(:list).should equal(@list)
      end

      it "should redirect to the created list" do
        do_post
        response.should redirect_to(list_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @list.should_receive(:save).and_return(false)
        post :create, :list => {}
      end
  
      it "should assign the invalid list for the view" do
        do_post
        assigns(:list).should equal(@list)
      end

      it "should re-render the 'new' template" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "responding to PUT /lists/1" do

    before(:each) do
      @list = mock_model(List, :to_param => "1")
      List.stub!(:find).and_return(@list)
    end
    
    describe "with successful update" do

      def do_put
        @list.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the list requested" do
        List.should_receive(:find).with("1").and_return(@list)
        do_put
      end

      it "should update the found list" do
        do_put
        assigns(:list).should equal(@list)
      end

      it "should assign the found list for the view" do
        do_put
        assigns(:list).should equal(@list)
      end

      it "should redirect to the list" do
        do_put
        response.should redirect_to(list_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @list.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should assign the found list for the view" do
        do_put
        assigns(:list).should equal(@list)
      end

      it "should re-render the 'edit' template" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "responding to DELETE /lists/1" do

    before(:each) do
      @list = mock_model(List, :destroy => true)
      List.stub!(:find).and_return(@list)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the list requested" do
      List.should_receive(:find).with("1").and_return(@list)
      do_delete
    end
  
    it "should call destroy on the found list" do
      @list.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the lists list" do
      do_delete
      response.should redirect_to(lists_url)
    end
  end
end

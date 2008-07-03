# Awsomo
# V.0.0.0.0.0.0.0.0.1 (2008)
# Gregory Mirzayantz for Nguma
# Based a lot on Bruce Williams's Aws_shopping plugin, thanks to him!

module Awsomo
	
	AWS_REST_URL = "http://ecs.amazonaws.com/onca/xml"
	AWS_SERVICE = "AWSECommerceService"
	AWS_VERSION = "2005-03-23"
	
	class AwsError < StandardError; end
  class TimeoutError < AwsError; end # catch Timeout errors with this
  class RequestError < AwsError; end # Aws request errors are that are caused by an invalid request
  class SystemError < AwsError; end # Aws system errors are that are caused by problems at Aws's end
	
	class Request
		
		attr_reader :aws_key_id, :aws_associate_id, :aws_default_operation, :aws_default_category
		@@config_params = nil # initialize config params class variable
		
		
		def initialize(params = {})
			@aws_key_id = self.class.config_params[:aws_key_id]
			@aws_associate_id = self.class.config_params[:aws_associate_id]
			@aws_default_operation = self.class.config_params[:aws_default_operation]
			@aws_default_category = self.class.config_params[:aws_default_category]
		end
		
		
		# Get config params from YAML config file stored in app config folder
		# Thanks [#person Bruce Williams #email bruce@codefluency.com]!
	  def self.config_params
	    return @@config_params if @@config_params
	    all_params = YAML.load_file("#{RAILS_ROOT}/config/awsomo.yml")
	    @@config_params = all_params[RAILS_ENV.to_sym] || all_params[:production]
	  end
	
		def search(q, options = {})
			request_url = build(q, options)
			
			begin
        response = Net::HTTP.get_response(URI.parse(request_url))
        raise RequestError, "Problem retrieving info from Amazon." unless response.is_a? Net::HTTPSuccess
      rescue Timeout::Error
        raise TimeoutError, "Amazon is currently unavailable. Please try again later"
      end
	    # parse xml response into Ruby Objects
			items = []
			xml_items(REXML::Document.new(response.body)).each do |xml_item|
				items << AwsomeItem.new(xml_item)
			end
			items
			
		end
		
		
		protected
		
		def xml_items(xml)
			xml.elements.to_a("//Item")
		end
		
		# This method builds the actual request
		def build(q, options = {})
			operation = options[:operation] || aws_default_operation
			category = options[:category] || aws_default_category
			page = options[:page] || 1
			keywords = q.split(" ").join("_")
			
			req = "#{AWS_REST_URL}?Service=#{AWS_SERVICE}&Version=#{AWS_VERSION}&Operation=#{operation}&ContentType=text%2Fxml"
			req += "&SubscriptionId=#{aws_key_id}&XMLEscaping=Double&SearchIndex=#{category}&ItemPage=#{page}"
			req += "&Keywords=#{keywords}&ResponseGroup=Images,ItemAttributes,Medium,SalesRank"
			
			req
		end
	end
	
	class AwsomeItem	
		attr_reader :title, :amount, :url, :brand, :thumbnail
    def initialize(item)
      @title = item.elements["ItemAttributes/Title"].text
			@url = item.elements["DetailPageURL"].text if item.elements["DetailPageURL"]
			@amount = item.elements["ItemAttributes/ListPrice/Amount"].text.to_i if item.elements["ItemAttributes/ListPrice/Amount"]
			@brand = item.elements["ItemAttributes/Brand"].text if item.elements["ItemAttributes/Brand"]
			@thumbnail = item.elements["SmallImage/URL"].text if item.elements["SmallImage/URL"]
    end
		
	end
	

	
end
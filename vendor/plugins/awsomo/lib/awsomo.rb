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
		
		attr_reader :aws_key_id, :aws_associate_id, :aws_default_operation, :aws_default_category, :call_params
		@@config_params = nil # initialize config params class variable
		
		
		def initialize(params = {})
			@aws_key_id = self.class.config_params[:aws_key_id]
			@aws_associate_id = self.class.config_params[:aws_associate_id]
			@aws_default_operation = self.class.config_params[:aws_default_operation]
			@aws_default_category = self.class.config_params[:aws_default_category]
			@call_params = params
		end
		
		
		# Get config params from YAML config file stored in app config folder
		# Thanks [#person Bruce Williams #email bruce@codefluency.com]!
	  def self.config_params
	    return @@config_params if @@config_params
	    all_params = YAML.load_file("#{RAILS_ROOT}/config/awsomo.yml")
	    @@config_params = all_params[RAILS_ENV.to_sym] || all_params[:production]
	  end
	
		def response
			Awsomo::Response.new(call(call_params)) 
		end
		
		def call(params)
			
			Net::HTTP.get_response(URI.parse(build(params)))
		end
		
		protected
		

		
		# This method builds the actual request
		def build(params)
			req = "#{AWS_REST_URL}?Service=#{AWS_SERVICE}&Version=#{AWS_VERSION}&Operation=#{params[:operation] || aws_default_operation}"
			req << "&ContentType=text%2Fxml&SubscriptionId=#{aws_key_id}&XMLEscaping=Double"
			req << "&SearchIndex=#{params[:category] || aws_default_category}&ItemPage=#{params[:page] || 1}&Keywords=#{params[:query].split(" ").join("_")}&ResponseGroup=Images,ItemAttributes,Medium,SalesRank,ItemIds" if params[:query]
			req << "&ItemId=#{params[:item_id]}&ResponseGroup=Images,ItemAttributes,Medium,SalesRank" if params[:item_id]
			
			req
		end
	end
	
	class AwsomeItem	
		attr_reader :title, :amount, :url, :thumbnail, :id, :image, :features
    def initialize(item)
      @title = item.elements["ItemAttributes/Title"].text
			@url = item.elements["DetailPageURL"].text if item.elements["DetailPageURL"]
			@amount = item.elements["ItemAttributes/ListPrice/FormattedPrice"].text rescue nil
		 #@brand = item.elements["ItemAttributes/Brand"].text if item.elements["ItemAttributes/Brand"]
			@thumbnail = item.elements["SmallImage/URL"].text rescue nil
			@image = item.elements["LargeImage/URL"].text rescue nil
			@id  = item.elements["ASIN"].text
			@features = item.elements["ItemAttributes/"].text
    end
		
	end
	
	
	class Response
		attr_reader :body
		def initialize(response, request = nil)
			begin
        raise RequestError, "Problem retrieving info from Amazon." unless response.is_a? Net::HTTPSuccess
      rescue Timeout::Error
        raise TimeoutError, "Amazon is currently unavailable. Please try again later"
      end
			@body = response.body
		end
		
		def items
			# parse xml response into Ruby Objects
			items = []
			xml_items(REXML::Document.new(body)).each do |xml_item|
				items << AwsomeItem.new(xml_item)
			end
			items
		end
		
		def item
			items.first
		end
		
		def xml_items(xml)
			xml.elements.to_a("//Item")
		end
	end

	
end
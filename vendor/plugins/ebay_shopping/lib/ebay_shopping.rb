# TODO: 
# -- Add hook and info level logging if request generates warning
# -- Add support for FindHalfProducts, FindPopularSearches, FindProducts, FindReviewsAndGuides, GetCategoryInfo, GeteBayTime, GetItemStatus, GetShippingCosts, GetUserProfile
# -- Add possibility to have different affiliates for different countries
# -- Add some documentation

module EbayShopping
  EBAY_SHOPPING_API_URL     = "open.api.ebay.com"
  EBAY_SHOPPING_API_PATH    = "/shopping"
  EBAY_API_VERSION          = 547 # version of API when this version of shopping library was written
  EBAY_SITES                = { 15  => "Australia",
                                16  => "Austria",
                                123 => "Belgium (Dutch)",
                                23  => "Belgium (French)",
                                2   => "Canada", 
                                210 => "Canada (French)", 
                                71  => "France",
                                77  => "Germany",
                                223 => "China",
                                201 => "Hong Kong",
                                203 => "India",
                                205 => "Ireland",
                                101 => "Italy",
                                207 => "Malaysia",
                                146 => "Netherlands",
                                211 => "Philippines",
                                212 => "Poland",
                                216 => "Singapore",
                                186 => "Spain",
                                218 => "Sweden",
                                193 => "Switzerland",
                                196 => "Taiwan",
                                3   => "UK",
                                0   => "US"
                              }

  # define custom errors
  class EbayError < StandardError; end
  class TimeoutError < EbayError; end # catch Timeout errors with this
  class RequestError < EbayError; end # Ebay request errors are that are caused by an invalid request
  class SystemError < EbayError; end # Ebay system errors are that are caused by problems at Ebay's end
  
  # This is the Ebay Request class that wraps up the whole of the generation of the request, and getting the response
  # (the parsing of which is handled by the Response class).
  # 
  class Request
    attr_reader   :affiliate_id, :affiliate_partner, :affiliate_shopper_id, :app_id, :callname, :call_params, :site_id
    @@config_params = nil # initialize config params class variable
    
    def initialize(callname, params={})
      @callname             = callname
      @site_id              = params.delete(:site_id) || self.class.config_params[:site_id]
      @app_id               = self.class.config_params[:app_id]
      @affiliate_id         = self.class.config_params[:affiliate_id]
      @affiliate_partner    = self.class.config_params[:affiliate_partner]
      @affiliate_shopper_id = self.class.config_params[:affiliate_shopper_id]
      @app_id               = self.class.config_params[:app_id]
      @call_params          = params
    end
    
    # Get config params from YAML config file stored in app config folder
    def self.config_params
      return @@config_params if @@config_params
      all_params = YAML.load_file("#{RAILS_ROOT}/config/ebay.yml")
      @@config_params = all_params[RAILS_ENV.to_sym] || all_params[:production]
    end
    
    # The response method instantiates a response object of appropriate class, i.e. :find_items_advanced generates FindItemsAdvancedResponse.
    # Note we pass self (i.e. the request object) to the new response oject, so we can access the query params and other useful methods from 
    # the response
    def response
      ebay_response = call(url_from(callname, call_params))
      "EbayShopping::#{callname.to_s.camelize}Response".constantize.new(ebay_response, self) 
    end
    
    def site_name
      @site_name ||= EBAY_SITES[site_id.to_i]
    end
    
    def ebay_error_raised(response=nil)
    end
    
    protected
    # Protected method that wraps a call to the ebay url given. Allows for simple caching (not implemented in this plugin -- add yours using MemCached, 
    # the DB or file system) by calling #cached_response before making the call, and passing the response to #cache_response after making it.
    def call(url)
      check_error_cache
      return cached_xml_response if cached_xml_response
      fresh_response = _http_get(url)
      cache_response(fresh_response)
      fresh_response
    end
    
    # The protected cached_xml_response method (along with #cache_response and #perform_caching) allows you to easily add caching. It is called before a request is made and 
    # if it returns a value that evaluates to true (i.e. not be nil or false) that will be used instead of the call to ebay being made. If you want to use caching simply overwrite 
    # this and the other cache methods. The url for the ebay request is available as the @url instance variable. This allows you to associate all cached responses with a specific url.
    # 
    # Expiring of stale cached responses is the responsibility your cached_response method. Have it return nil (if the cached response is stale) and a fresh call will be made to ebay 
    def cached_xml_response
    end
    
    
    # The protected #cache_response method (along with #cached_response) allows you to easily add caching. It is called after a request is made and passed the response from 
    # that request. The url for the ebay request is available as the @url instance variable. This allows you to associate all cached responses with a specific url
    def cache_response(response=nil)
    end
    
    # THis protected method is run before the request to the ebay api is made to check that no previous requests to the url in question have raised errors. If you want to 
    # pass the ebay comatibility test you need to cache errors (and they shouldn't be expired until the problem has been resolved)
    def check_error_cache   
    end
    
    # Generates ebay request URL from the rubyized form of the ebay method. Converts the call parameters into a key=value pair
    def url_from(method, params={})
      base_url = "http://#{EBAY_SHOPPING_API_URL + EBAY_SHOPPING_API_PATH}?version=#{EBAY_API_VERSION}&appid=#{app_id}&callname=#{method.to_s.camelize}&"
      config_queries = affiliate_partner&&affiliate_id ? "trackingpartnercode=#{affiliate_partner}&trackingid=#{affiliate_id}&affiliateuserid=#{affiliate_shopper_id}&" : "" # add affiliate_id and partner if set, otherwise nothing
      siteid_query = site_id ? "siteid=#{site_id}&" : ""
      @url = base_url + siteid_query + config_queries + _query_params_from(params)
    end

    # Turns the params into key=value pair, joined by & escaping the values. NB if the value is an array, join elements with commas. Also ebay wants us to use %20 for space, instead of +.
    # NB we sort the items in alpha order before joining them so the order is consistent, allowing us to ensure the same request always generates the same url (important if we cache)
    def _query_params_from(params) #:nodoc:
      query_params = params.empty? ? "" : params.delete_if { |k,v| v.nil? }.collect  do |i|
        "#{i[0].to_s.camelize}=" + (i[1].is_a?(Array) ? i[1] : [i[1]]).collect{ |v| CGI::escape(v.to_s).gsub('+', '%20')}.join(',')
      end.sort.join("&")       
    end
    
    def _http_get(url) #:nodoc:
      response = nil 
      RAILS_DEFAULT_LOGGER.debug "********Ebay Shopping API request = #{url}"
      url = URI.parse(url)
      request = Net::HTTP.new(url.host, url.port)
      request.read_timeout = 5 # set timeout at 5 seconds
      begin
        response = request.get(url.request_uri)
        raise RequestError, "Problem retrieving info from Ebay." unless response.is_a? Net::HTTPSuccess
      rescue Timeout::Error
        raise TimeoutError, "Ebay is currently unavailable. Please try again later" # i.e. raise EbayShopping::TimeoutError
      end
      RAILS_DEFAULT_LOGGER.debug "********Ebay Shopping API response = #{response.inspect}. #{response.body if response.respond_to?(:body)}"
      response.body
    end
  end

  # The EbayShopping::Response class is the parent response class for all EbayShopping API responses, implemented the core parsing methods. Note the 
  # full parsed response is available through the full_response reader method, and the query parameters for the request which generated the response
  # through the query_params reader method (which is useful if you want to make the request again, with altered params
  class Response
    attr_reader :errors, :full_response, :request
    def initialize(response_body, request=nil)
      @full_response =  XmlSimple.xml_in(response_body, 'ForceArray' => false)
      @request = request
      if @full_response["Ack"] == "Failure" # options are "Success", "Failure", "Warning". For the moment, treat "Warning" as "Success"
        @errors = @full_response["Errors"]
        @request.ebay_error_raised(@errors)
        raise TimeoutError, @errors["LongMessage"] if @errors["ErrorCode"] == "1.23"
        raise SystemError, @errors["LongMessage"] if @errors["ErrorClassification"] == "SystemError"
        raise RequestError, @errors["LongMessage"] unless @errors["ErrorClassification"] == "SystemError"
      end
    end
    
    # turns xml_items into EbayShopping::Items
    def items
      return [] if total_items == 0 # don't bother parsing if no items
      @items ||= (xml_items.is_a?(Array) ? xml_items : [xml_items]).collect { |i| Item.new(i) } # because we don't ForceArray when parsing XML response if only one item is returned it will not be an array, so we make it into one.
    end
    
    # Extracts the items from the response. Often overridden by response subclasses
    def xml_items
      full_response["Item"]
    end
    
    # returns total number of items that fitted the query, as parsed from the "TotalItems" field in the response. Will return nil if no "TotalItems" field
    def total_items
      @total_items ||= full_response["TotalItems"]&&full_response["TotalItems"].to_i
    end
    
    # returns total pages of items that fitted the query, as parsed from the "TotalPages" field in the response. Will return nil if no "TotalPages" field
    def total_pages
      @total_pages ||= full_response["TotalPages"]&&full_response["TotalPages"].to_i
    end
    
    # returns current page number of items that fitted the query, as parsed from the "PageNumber" field in the response. Will return nil if no "PageNumber" field
    def page_number
      @page_number ||= full_response["PageNumber"]&&full_response["PageNumber"].to_i
    end
  end
  
  # Response subclass for FindItems request response
  class FindItemsResponse < Response
  end
  
  # Response subclass for FindItemsAdvanced request response
  class FindItemsAdvancedResponse < Response
    def xml_items
      full_response["SearchResult"]["ItemArray"]["Item"]
    end
  end
  
  # Response subclass for GetSingleItem request response
  class GetSingleItemResponse < Response
    def items
      @items ||= [item]
    end
    
    # Convenience method which allows us to write something like single_item_response.item
    def item
      @item ||= Item.new(full_response["Item"])
    end
  end
  
  # Response subclass for FindPopularItems request response
  class FindPopularItemsResponse < Response
    def xml_items
      full_response["ItemArray"]["Item"]
    end
  end
  
  # Response subclass for GetMultipleItems request response
  class GetMultipleItemsResponse < Response    
  end
  
  # Response subclass for GetCategoryInfo request response
  class GetCategoryInfoResponse < Response    
  end
  
  # Response subclass for FindProducts request response
  class FindProductsResponse < Response    
    # turns products into EbayShopping::Products
    def products
      # return [] if total_items == 0 # don't bother parsing if no items
      xml_products = full_response["Product"]
      @products ||= (xml_products.is_a?(Array) ? xml_products : [xml_products]).collect { |i| Product.new(i) } # because we don't ForceArray when parsing XML response if only one product is returned it will not be an array, so we make it into one.
    end
  end
  
  
  # 
  # The EbayShopping::GenericItem class is the parent class of Item and Product classes and provides the core behaviour of these classes. Attributes 
  # are accessible either by creating a reader method corresponding to the 'rubyized' version of the parameter's name (e.g gallery_url for GalleryURL)
  # or by the all-purpose [] method for less-frequent ones, e.g. item["Storefront"].
  # Where the attribute is a string, a simple reader method is best for accessing it. Otherwise (e.g. converted_current_price) a specific method 
  # is used to convert it into something more useful
  # 
  class GenericItem
    attr_reader :all_params, # used to access_original_hash
                :title
    def initialize(params)
      @all_params = params
      params.each_key { |p| self.instance_variable_set("@#{p.underscore}", params[p]) if self.respond_to?(p.underscore.to_sym) }
    end
    
    # Utility method which allows access to original params, especially those that haven't been converted into instance variables, so 
    # if the params hash (i.e. the item xml from the response) includes  "SomeOtherAttribute" => "Some words here", this can be accessed
    # via item["SomeOtherAttribute"]
    def [](param_name)
      all_params[param_name]
    end
    
  end
  
  # 
  # The EbayShopping::Item class is used for the items returned by common ebay search methods (e.g. FindItemsAdvanced, GetSingleItem, etc).
  # It provides a number of ways of accessing the item's attributes, with reader methods named after the most common attributes, and an 
  # all-purpose [] method for less-frequent ones, e.g. item["Storefront"].
  # 
  class Item < GenericItem
    attr_reader :bid_count,
                :description,
                :gallery_url,
                :item_id,
                :primary_category_name,
                :view_item_url_for_natural_search
    
    def converted_current_price
      EbayShopping::Money.new(@converted_current_price) if @converted_current_price
    end
    
    # This is calculated from the end time (and ignores the time_left attribute, which is stored in the IS8601 duration format, which I haven't seen a 
    # conversion for, though it's prob easy to do)
    def time_left
      duration = (end_time - Time.now).to_i
      result, res = [], 0
      [["days", 86400], ["hours", 3600], ["minutes", 60]].each do |i|
        res, duration  = duration.divmod(i[1])
        result << "#{res} #{i[0]}" if res > 0
      end
      result.join(", ")
    end
    
    # Returns the end time of the item's auction as UTC time
    def end_time
      Time.xmlschema(@end_time).getlocal
    end
  end
  
  # 
  # The EbayShopping::Product class is used for the products returned by the Product related searches (e.g. FindProducts, FindHalfProducts).
  # It provides a number of ways of accessing the product's attributes, with reader methods named after the most common attributes, and an 
  # all-purpose [] method for less-frequent ones, e.g. item["DisplayStockPhotos"].
  # 
  class Product < GenericItem
    attr_reader :product_id
  end
  
  # The EbayShopping::Money class is used to store ebay currency hashes, which consist of a currency code and a floating point number,
  # e.g. "currencyID"=>"GBP", "content"=>"5.99"
  class Money
    attr_reader :currency_id, :content
    CURRENCY_SYMBOLS = {"AUD" => "AU$",
                        "CAD" => "CA$",
                        "GBP" => "£",
                        "USD" => "$"}
    
    def initialize(currency_hash)
      @currency_id = currency_hash["currencyID"]
      @content = currency_hash["content"].to_f
    end
    
    def to_s
      currency_symbol = CURRENCY_SYMBOLS[currency_id] || "#{currency_id} "
      "#{currency_symbol}#{format('%0.2f', content)}"
    end
  end
end
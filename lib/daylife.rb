require 'rexml/document'
require 'net/http'
require 'md5'
require 'cgi'

module Daylife
  class API
    DEFAULT_PROTOCOL = 'xmlrest'
    DEFAULT_VERSION = '4.2'
    DEFAULT_SERVER = 'freeapi.daylife.com'
    
    CORE_IDENTIFIER_MAP = {'search' => :query, 'topic' => :name, 'article' => :article_id, 'quote' => :quote_id, 'image' => :image_id}
    
    def initialize(access_key, shared_secret, options = {})
      @protocol = options[:protocol] || DEFAULT_PROTOCOL
      @version = options[:version] || DEFAULT_VERSION
      @server = options[:server] || DEFAULT_SERVER
      
      @access_key = access_key
      @shared_secret = shared_secret
    end
    
    def execute(service_name, method_name, parameters = {})
      # Create the signature
      core_identifier = parameters[:core_identfier] || parameters[CORE_IDENTIFIER_MAP[service_name]]
      parameters[:signature] = Digest::MD5.hexdigest(@access_key + @shared_secret + core_identifier) unless parameters[:signature]
      
      # Convert Time objects to strings with correct format
      parameters[:start_time] = parameters[:start_time].strftime("%Y-%m-%d %H:%M:%S") if(parameters[:start_time] and parameters[:start_time].kind_of? Time)
      parameters[:end_time] = parameters[:end_time].strftime("%Y-%m-%d %H:%M:%S") if(parameters[:end_time] and parameters[:end_time].kind_of? Time)
    
      # Build the URL  
      parameters[:accesskey] = @access_key      
      url = "http://#{@server}/#{@protocol}/publicapi/#{@version}/#{service_name}_#{method_name}"
      param_string = parameters.collect {|k,v| "#{k}=#{CGI.escape(v.to_s)}"}.join("&")
      url += "?" + param_string if parameters.length > 0
      
      http_response = Net::HTTP.get_response(URI.parse(url))
      
      # TODO: Check for 404 etc.
      
      Daylife::Response.new(http_response.body)
    end
  end

  class Response
    attr_accessor :document
    attr_accessor :root

    def initialize(response)
      @document = REXML::Document.new(response)
      @nodes = Daylife::Node.new(@document.elements['response/payload'])
    end

    def code
      @document.elements["response/code"].text.to_i
    end

    def message
      @document.elements["response/message"].text  
    end

    def success?
      self.code == 2001
    end
    
    # Pass through missing methods to the daylife node for easy access to the api responses
    def method_missing(name, *args)
      @nodes.send(name, args)
    end
  end

  # This class represents a level in the Daylife response XML, used for easy access to the API results
  class Node
    include Enumerable
  
    def initialize(node)
      @document = node
    end
  
    def each
      @document.each {|e| yield Daylife::Node.new(e) }
    end
  
    def [](index)
      return Daylife::Node.new(@document[index])
    end
  
    def size
      return @document.size
    end
  
    def method_missing(name, *args)
      return nil if @document.kind_of? Array
    
      name = name.to_s
    
      if name.reverse[0..0] == 's'
        # If there is an 's' then assume this is an array of elements we are trying to access
        elem = Array.new
        @document.elements.each("#{name[0..name.length-2]}") {|e| elem << e}
        return Daylife::Node.new(elem)
      else
        elem = @document.elements[name]
        if(elem.size > 1)
          # If the element has > 1 child elements then we assume it has no content
          return Daylife::Node.new(elem)
        else
          value = elem.text
          value = value.to_i if(type = elem.attributes["type"] and (type == 'int4' or type == 'int8'))
          value = Time.parse(value) if(name == 'timestamp')
          return value
        end
      end
    end
  end
end

class Group < ActiveRecord::Base
	
	has_many :connections, :as => :object, :class_name => "Polyco", :dependent => :destroy
end
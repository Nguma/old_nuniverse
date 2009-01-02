class Fact < ActiveRecord::Base
	
	has_many :connections, :as => :object, :class_name => 'Polyco'
# 	has_many :elements, :through => :connections, :source => :object

end

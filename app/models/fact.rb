class Fact < ActiveRecord::Base
	
	has_many :connections, :as => :object, :class_name => 'Polyco'
	has_many :subjects, :through => :connections, :source => :subject, :source_type => "Nuniverse"
	

end

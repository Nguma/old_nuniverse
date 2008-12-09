class Location < ActiveRecord::Base
		has_many :taggings, :as => :taggable
end
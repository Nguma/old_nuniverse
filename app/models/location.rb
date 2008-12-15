class Location < ActiveRecord::Base
		has_many :taggings, :as => :taggable
		belongs_to :tag
end
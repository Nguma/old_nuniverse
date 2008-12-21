class Video < ActiveRecord::Base
	has_many :taggings, :as => :taggable
end	
class Perspective < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag
	
	def kind
		return "everyone" if self.tag_id.to_i == 0
		return "personal" if self.tag == self.user.tag 
		return tag.kind
	end
	
	named_scope :favorites, :conditions => ['favorite = 1']
	
	def members
		case self.kind
		when "user","personal","everyone"
			return self.tag
		when "service"
			return nil
		when "group"
			Tagging.select(
				:user => self.user.tag,
				:mode => "personal",
				:subject => @perspective.tag,
				:kind => "user",
				:paginate => false
				).collect{|c| c.user}.uniq!
		end
		
	end
end

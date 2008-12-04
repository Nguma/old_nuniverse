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
		when "user","personal"
			return self.tag
		when "everyone"
			return nil
		when "service"
			return nil
		when "group"
	
			 Connection.with_subject(self.tag).with_kind('user').tagged('member|founder').collect {|c| c.object}
		end
		
	end
end

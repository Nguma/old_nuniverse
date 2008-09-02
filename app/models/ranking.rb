class Ranking < ActiveRecord::Base
	belongs_to :tagging
	belongs_to :user
	
	def self.find_or_create(params)

		r = Ranking.find(:first, :conditions => ["tagging_id = ? AND user_id = ? ", params[:tagging].id, params[:user].id])
		r = Ranking.create(
			:tagging => params[:tagging],
			:user => params[:user]
		) if r.nil?
		r
	end
end

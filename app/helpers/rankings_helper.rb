module RankingsHelper
	def pretty_score(score)
		sc = sprintf('%.1f', score.round.to_i)
		sc = sc.gsub('.0','')
		sc = "+#{sc}" if sc.to_i > 0
		sc
	end
	
	def render_stat(stat, params = {})
		params[:stat] = stat
		params[:color] = Ranking.color(stat.score)
		render :partial => "/nuniverse/stat", :locals => params
	end
end

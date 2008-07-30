module Rssr
	def self.news(feed)
		news = [] 
		RSS::Parser.parse(open(feed).read, false).items.each do |item|
			news << Rssr::NewsItem.new(item)
		end
		news
	end
	
	class NewsItem
		attr_reader :label, :description, :image, :date, :link
		def initialize(item)
			@label = item.title
			
			d = Hpricot(item.description)
			d.search("a").remove
			@description = d.to_html
			@link = item.link
			@date = item.pubDate
		end
		
		def time_from_now
			(Time.now - date).to_i
      result, res = [], 0
      [["days", 86400], ["hours", 3600], ["minutes", 60]].each do |i|
        res, duration  = duration.divmod(i[1])
        result << "#{res} #{i[0]}" if res > 0
      end
      result.join(", ")
			result << " ago."
		end
	end
end
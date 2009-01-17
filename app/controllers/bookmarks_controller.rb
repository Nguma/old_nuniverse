class BookmarksController < ApplicationController

	before_filter :redirect_out
	
	def redirect_out
		
	end
	
	def create
		@bookmark = Bookmark.new(params[:bookmark])
		urlscan = @bookmark.url.scan(/((https?:\/\/)?[a-z0-9\-\_]+\.{1}([a-z0-9\-\_]+\.[a-z]{2,5})\S*)/ix)[0]
		
		@bookmark.url = "http://#{bookmark.url}" if urlscan[1].nil?
		begin
			doc = Hpricot open @bookmark.url
			@bookmark.name = (doc/:title).inner_html rescue "#{urlscan[2]} page"
			@bookmark.url = url
			@bookmark.description = (doc/"meta[@name=description]").first.attributes['content'] rescue (doc/:p).first.inner_html

			(doc/:img).each do |img|
				if img.attributes['height'].to_i >= 50
					img.attributes['src'] = "#{url}/#{img.attributes['src']}" unless img.attributes['src'].match(/^http/)
					@images << img
				end
			end
			@bookmark.images << Image.create(:source_url => @images.first.attributes['src']) 
		rescue
		end
		@bookmark.save
		connect_to_object(@bookmark)
		
		respond_to do |format|
			format.html { redirect_back_or_default('/')}
			format.js {}
		end
	end
end
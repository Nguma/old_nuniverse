class CommentsController < ApplicationController
	
	before_filter :find_user
	before_filter :find_comment, :only => [:show, :destroy]
	
	def create
		@comment = Comment.create(params[:comment])
		@tokens = Nuniversal.tokenize(@comment.body)
		
		@tokens.each do |token|
			# n = Nuniverse.search(match[1].gsub('-',' '))

			unless token.nil?
				n = Nuniverse.find_or_create(token)
				Polyco.create(:subject => n, :object => @comment, :state => 'active') rescue nil
				Polyco.create(:subject => n, :object => @comment.parent, :state => 'active') rescue nil
			end

		end
		
		asin = @comment.body.scan(/(http:\/\/www\.amazon\.com\/.+\/(B0\w+)\/.+)(\s|$)/)[0]

		unless asin.nil? || asin[1].nil?
			n = Nuniverse.find_by_unique_name(asin[1])
			awsobject = Finder::Search.find(:item_id => asin[1], :service => 'amazon', :operation => "ItemLookup")[0]
			if n.nil?
			n = Nuniverse.create(:name => awsobject[:name], :unique_name => asin[1], :description => awsobject[:description]) 
			n.images << Image.create(:source_url => awsobject[:image])
			end
			# n.bookmarks << Bookmark.create(:name => "#{awsobject[:name]} on Amazon", :url => awsobject[:url])
			Polyco.create(:subject => n, :object => @comment, :state => 'active') rescue nil
			Polyco.create(:subject => n, :object => @comment.parent, :state => 'active') rescue nil
		
			@comment.body = @comment.body.gsub(/(http:\/\/www\.amazon\.com\/.+\/(B0\w+)\/.+)(\s|$)/,"##{asin[1]}")
		
		end
		
		ikea = @comment.body.scan(/(http:\/\/www\.ikea\.com\/.+\/products\/(\w+))/)[0]
		
		unless ikea.nil? || ikea[1].nil?
			n = Nuniverse.find_by_unique_name("ikea-#{ikea[1]}")
			if n.nil?
			
				doc = Hpricot open ikea[0]
				n = Nuniverse.create(:unique_name => "ikea-#{ikea[1]}", :name => doc.at("#productName").inner_html.titleize, :description => doc.at("#productType").inner_html )
				n.bookmarks << Bookmark.create(:name => "#{n.name} at Ikea", :url => ikea[0])
				n.images << Image.create(:source_url => "http://www.ikea.com/#{doc.at("#productImg").attributes['src']}")
				n.tags << Tag.find_or_create(:name => n.description)

			end
			Polyco.create(:subject => n, :object => @comment, :state => 'active') rescue nil
			Polyco.create(:subject => n, :object => @comment.parent, :state => 'active') rescue nil

			@comment.body = @comment.body.gsub(ikea[0],"#ikea-#{ikea[1]}")
		end
		
		urlscan = @comment.body.scan(/((https?:\/\/)?[a-z0-9]+[-.]{1}([a-z0-9]+\.[a-z]{2,5})\S*)/ix)[0]
	
		
		unless urlscan.nil?
			url ||= "#{urlscan[1].nil? ? "http://" : nil}#{urlscan[0]}"
			@bookmark = Bookmark.find(:first, :conditions => ['url = ?', url]) || Bookmark.new
				
				doc = Hpricot open url rescue nil
				if doc
					@bookmark.name = (doc/:title).inner_html rescue "#{urlscan[2]} page"
					@bookmark.url = url
					@bookmark.description = (doc/"meta[@name=description]").first.attributes['content'] rescue ""
					@bookmark.save
				end
				# (doc/:img).each do |img|
				# 	if img.attributes['height'].to_i >= 50
				# 		img.attributes['src'] = "#{url}/#{img.attributes['src']}" unless img.attributes['src'].match(/^http/)
				# 		@images <<  img  unless !img.attributes['src'].match(/(\.)(jpg|png)$/)
				# 	end
				# end
				# @bookmark.images << Image.create(:source_url => @images.first.attributes['src']) 
			
			@bookmark.save
			@comment.parent.bookmarks << @bookmark
			
		end

		
		@comment.save
		#Polyco.create(:subject => @comment, :object_id => params[:object][:id], :object_type => params[:object][:type]) if params[:object]
		respond_to do |f|
			f.html { redirect_back_or_default('/')}
			f.js {}
		end
	end
	
	def new
		@subject = Tag.find(params[:subject]) 
		@kind = params[:kind] || "note"
		respond_to do |f|
			f.html {}
			f.js {}
		end
	end

	
	def show

		respond_to do |f|
			f.html {}
			f.js { render :layout => false}
		end
	end
	
	def destroy
		@comment.destroy

    respond_to do |format|
      format.html { redirect_back_or_default('/') }
			format.js {head :ok}
      format.xml  { head :ok }
    end
	end
	
	protected
	def find_comment
		@comment = Comment.find(params[:id])
	end
end

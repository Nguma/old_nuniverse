class Token
	attr_reader :property, :source, :formula
	def initialize(params)
		@property = Tag.find_by_name(params[:property])
		# @group = Group.find_by_unique_name(params[:group])
		@source = params[:source]
		@formula = params[:formula] || build_formula
	end		
	
	def build_formula
		"<#{@property.name}>"
	end
	
	def result
		
		if @property.name == "name"
			return @source.name
		else
			
			return @source.property(@property).subject.body rescue ""
		end
	end
	
	def self.traverse(token)
		url = "http://en.wikipedia.org/wiki/#{token}?action=edit"
		father = Nuniverse.find_or_create(token)
		
		doc = Hpricot open url
		if doc
			content = (doc/:textarea).first.inner_text rescue nil
			if content
				p = content.scan(/\n\'\'\'(.*)\n/)[0] rescue []
				p = p[0].split(". ").first.gsub(/\<ref .*\<\/ref\>/, '').gsub(/\'\'\'/,'') rescue ""
				sentence = p.gsub(/\{\{.*\}\}/,'')
				f = Fact.create(:body => sentence.strip)
				f.objects << father rescue nil
				Nuniversal.tokenize(sentence).each do |token|
					unless Nuniverse.find_by_unique_name(Nuniversal.sanatize(token))
						n = Nuniverse.find_or_create(token)
						f.subjects << n rescue nil
						father.nuniverses << n rescue nil
						Nuniversal.traverse(Nuniversal.sanatize(token)) 
					end
				end
			end
		end
		
	end
end
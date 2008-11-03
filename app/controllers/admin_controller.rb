class AdminController < ApplicationController
	skip_before_filter :invitation_required
	before_filter :admin_required
	
	def index
	end
	
	def users
		@users = User.find(:all).paginate(:page => params[:page] || 1, :per_page => 20)
	end
	
	def send_activation_code
		@user = User.find(params[:id])
		UserMailer.deliver_activation_code(@user)
		redirect_to "/admin/users"
	end
	
	def permissions
		@page = params[:page] || 1
		@permissions = Permission.find(:all).paginate(:page => @page, :per_page => 10)
		
	end
	
	def ct 

		cts = [
			["Alexis Simon Belle","/wiki/Alexis_Simon_Belle","1674‚1734"],
			["Giovanni Bellini","/wiki/Giovanni_Bellini",""],
			["Gentile Bellini","/wiki/Gentile_Bellini",""],
			["Jacopo Bellini","/wiki/Jacopo_Bellini",""],
			["Vanessa Bell","/wiki/Vanessa_Bell","1879‚1961"],
			["Bernardo Bellotto","/wiki/Bernardo_Bellotto","1721‚1780"],
			["George Wesley Bellows","/wiki/George_Wesley_Bellows","1882‚1925"],
			["Ludwig Bemelmans","/wiki/Ludwig_Bemelmans","1898‚1962"],
			["Jason Benjamin","/wiki/Jason_Benjamin",""],
			["Martin Benka","/wiki/Martin_Benka","1888‚1977"],
			["Wilhelm Bendz","/wiki/Wilhelm_Bendz","1804‚1832"],
			["Frank Weston Benson","/wiki/Frank_Weston_Benson","1862‚1951"],
			["Thomas Hart Benton","/wiki/Thomas_Hart_Benton_(painter)","1889‚1975"],
			["Alexander Benois","/wiki/Alexander_Benois","1870‚1960"],
			["Jean B√©raud","/wiki/Jean_B%C3%A9raud","1849‚1935"],
			["Helen Berman","/wiki/Helen_Berman",""],
			["Emerik Bernard","",""],
			["Emile Bernard","/wiki/Emile_Bernard","1868‚1941"],
			["Janez Bernik","",""],
			["Gian Lorenzo Bernini","/wiki/Gian_Lorenzo_Bernini","1598‚1680"],
			["Morris Louis Bernstein","/wiki/Morris_Louis_Bernstein","1912‚1962"],
			["Elsa Beskow","/wiki/Elsa_Beskow","1874‚1953"],
			["Henryka Beyer","","1782‚1855"],
			["Lujo Bezeredi","/wiki/Lujo_Bezeredi","1898‚1979"],
			["George Biddle","/wiki/George_Biddle","1885‚1973"],
			["Albert Bierstadt","/wiki/Albert_Bierstadt","1830‚1902"],
			["Ivan Bilibin","/wiki/Ivan_Bilibin","1876‚1924"],
			["Anna Bilinska-Bohdanowiczowa","","1857‚1893"],
			["Ejler Bille","/wiki/Ejler_Bille","1910‚2004"],
			["Charles Billich","/wiki/Charles_Billich",""],
			["Henry Billings","","1901‚1987"],
			["George Caleb Bingham","/wiki/George_Caleb_Bingham","1811‚1879"],
			["S J 'Lamorna' Birch","/wiki/Lamorna_Birch","1869‚1955"],
			["Tim Biskup","/wiki/Tim_Biskup",""],
			["Wilhelm Bissen","/wiki/Wilhelm_Bissen","1836‚1913"],
			["Charles Blackman","/wiki/Charles_Blackman",""],
			["Basil Blackshaw","/wiki/Basil_Blackshaw",""],
			["William Blake","/wiki/William_Blake","1757‚1827"],
			["Ralph Albert Blakelock","/wiki/Ralph_Albert_Blakelock","1847‚1919"],
			["Arnold Blanch","","1896‚1968"],
			["Ross Bleckner","/wiki/Ross_Bleckner",""],
			["Carl Heinrich Bloch","/wiki/Carl_Heinrich_Bloch","1834‚1890"],
			["Josef Block","/wiki/Josef_Block","1863‚1943"],
			["Izaak van den Blocke","","1572‚1626"],
			["Godfrey Blow","/wiki/Godfrey_Blow",""],
			["Peter Blume","/wiki/Peter_Blume","1906‚1992"],
			["Ditlev Blunck","/wiki/Ditlev_Blunck","1798‚1854"],
			["David Gilmour Blythe","/wiki/David_Gilmour_Blythe","1815‚1865"],
			["Anna Boch","/wiki/Anna_Boch","1848‚1936"],
			["Fran√ßois Bocion","/wiki/Fran%C3%A7ois_Bocion","1828‚1890"],
			["Thomas Bock","/wiki/Thomas_Bock","1793‚1855"],
			["Arnold B√∂cklin","/wiki/Arnold_B%C3%B6cklin","1827‚1901"],
			["Karl Bodmer","/wiki/Karl_Bodmer","1809‚1893"],
			["Krzysztof Boguszewski","/wiki/Krzysztof_Boguszewski","1906‚1988"],
			["Aaron Bohrod","/wiki/Aaron_Bohrod","1907‚1992"],
			["Maurice Boitel","/wiki/Maurice_Boitel",""],
			["Kees Bol","/wiki/Kees_Bol",""],
			["David Bomberg","/wiki/David_Bomberg","1890‚1957"],
			["Camille Bombois","/wiki/Camille_Bombois","1883‚1970"],
			["Rosa Bonheur","/wiki/Rosa_Bonheur","1822‚1899"],
			["Claude Bonin-Pissarro","",""],
			["Richard Parkes Bonington","/wiki/Richard_Parkes_Bonington","1802‚1828"],
			["Pierre Bonnard","/wiki/Pierre_Bonnard","1867‚1947"],
			["Francesco Bonsignori","/wiki/Francesco_Bonsignori","1460‚1519"],
			["Gerard ter Borch","/wiki/Gerard_ter_Borch","1617‚1681"],
			["Bogdan Borcic","",""],
			["Paul-√âmile Borduas","/wiki/Paul-%C3%89mile_Borduas","1905‚1960"],
			["Adolf Born","/wiki/Adolf_Born",""],
			["Vladimir Borovikovsky","/wiki/Vladimir_Borovikovsky","1757‚1825"],
			["Hieronymus Bosch","/wiki/Hieronymus_Bosch",""],
			["Ambrosius Bosschaert","/wiki/Ambrosius_Bosschaert","1573‚1612"],
			["Angel Botello","/wiki/Angel_Botello","1913‚1986"],
			["Fernando Botero","/wiki/Fernando_Botero",""],
			["Sandro Botticelli","/wiki/Sandro_Botticelli","1445‚1510"],
			["Fran√ßois Boucher","/wiki/Fran%C3%A7ois_Boucher","1703‚1770"],
			["Eug√®ne Boudin","/wiki/Eugene_Boudin","1824‚1898"],
			["William-Adolphe Bouguereau","/wiki/William-Adolphe_Bouguereau","1825‚1905"],
			["John Bourne","/wiki/John_Bourne_(artist)",""],
			["David Bowie","/wiki/David_Bowie",""],
			["Zlatyu Boyadzhiev","/wiki/Zlatyu_Boyadzhiev","1903‚1976"],
			["Arthur Boyd","/wiki/Arthur_Boyd","1920‚1999"],
			["Arthur Merric Boyd","/wiki/Arthur_Merric_Boyd","1862‚1940"],
			["David Boyd","/wiki/David_Boyd",""],
			["Penleigh Boyd","/wiki/Penleigh_Boyd","1890‚1923"],
			["P. Rostrup B√∏yesen","","1882‚1952"],
			["Olga Bozna≈Ñska","/wiki/Olga_Bozna%C5%84ska","1865‚1940"],
			["Louis Bouch√©","","1896‚1969"],
			["John Brack","/wiki/John_Brack","1920‚1999"],
			["Robert Brackman","/wiki/Robert_Brackman","1898‚1980"],
			["Marie Bracquemond","/wiki/Marie_Bracquemond","1841‚1916"],
			["Frank Bramblett","",""],
			["Christian Hilfgott Brand","/wiki/Johann_Christian_Brand","1694‚1756"],
			["Johann Christian Brand","/wiki/Johann_Christian_Brand","1722‚1795"],
			["Petr Brandl","/wiki/Petr_Brandl","1668‚1739"],
			["Jozef Brandt","/wiki/Jozef_Brandt","1841‚1915"],
			["Georges Braque","/wiki/Georges_Braque","1882‚1963"],
			["Robert J Brawley","/wiki/Robert_J_Brawley","1936 - 2006"],
			["Alan Bray","",""],
			["Carl Fredrik von Breda","/wiki/Carl_Fredrik_von_Breda","1759‚1818"],
			["George Hendrik Breitner","/wiki/George_Hendrik_Breitner","1857‚1923"],
			["Mark A. Brennan","/wiki/Mark_A._Brennan",""],
			["Art Brenner","/wiki/Art_Brenner",""],
			["Jules Breton","/wiki/Jules_Breton","1827‚1906"],
			["Breyten Breytenbach","/wiki/Breyten_Breytenbach",""],
			["Pierre Brissaud","/wiki/Pierre_Brissaud","1885‚1964"],
			["Louis le Brocquy","/wiki/Louis_le_Brocquy",""],
			["Ann Brockman","","1898 or 1899‚1943"],
			["Antoni Brodowski","/wiki/Antoni_Brodowski","1784‚1832"],
			["Agnolo Bronzino","/wiki/Agnolo_Bronzino","1503‚1572"],
			["Alexander Brook","","1898‚1980"],
			["Bertram Brooker","/wiki/Bertram_Brooker","1888‚1955"],
			["Allan Brooks","/wiki/Allan_Brooks","1869‚1946"],
			["Romaine Brooks","/wiki/Romaine_Brooks","1874‚1970"],
			["Cecily Brown","/wiki/Cecily_Brown",""],
			["Ford Madox Brown","/wiki/Ford_Madox_Brown","1821‚1893"],
			["Joan Brown","/wiki/Joan_Brown","1938‚1990"],
			["Rush Brown","",""],
			["V√°clav Bro≈æ√≠k","/wiki/V%C3%A1clav_Bro%C5%BE%C3%ADk","1851‚1901"],
			["Patrick Henry Bruce","/wiki/Patrick_Henry_Bruce","1881‚1936"],
			["Jan Brueghel the Elder","/wiki/Jan_Brueghel_the_Elder","1568‚1625"],
			["Jan Brueghel the Younger","/wiki/Jan_Brueghel_the_Younger","1601‚1678"],
			["Pieter Brueghel the Elder","/wiki/Pieter_Brueghel_the_Elder",""],
			["Pieter Brueghel the Younger","/wiki/Pieter_Brueghel_the_Younger","1564‚1638"],
			["Karl Briullov","/wiki/Karl_Briullov","1799‚1852"],
			["Tadeusz Brzozowski","/wiki/Tadeusz_Brzozowski_(painter)","1818‚1887"],
			["Ernest Buckmaster","/wiki/Ernest_Buckmaster","1897‚1968"],
			["Ota Buben√≠ƒçek","/wiki/Ota_Buben%C3%AD%C4%8Dek","1871‚1962"],
			["Bernard Buffet","/wiki/Bernard_Buffet","1928‚1999"],
			["Alexander Bugan","",""],
			["Vlaho Bukovac","/wiki/Vlaho_Bukovac","1855‚1922"],
			["Charles Ragland Bunnell","/wiki/Charles_Ragland_Bunnell","1897‚1968"],
			["Rupert Bunny","/wiki/Rupert_Bunny","1864‚1947"],
			["Elbridge Ayer Burbank","/wiki/Elbridge_Ayer_Burbank","1858‚1949"],
			["Charles Ephraim Burchfield","/wiki/Charles_Ephraim_Burchfield","1893‚1967"],
			["Hans Burgkmair","/wiki/Hans_Burgkmair","1473‚1531"],
			["Francisco de Burgos Mantilla","/wiki/Francisco_de_Burgos_Mantilla","1612‚1672"],
			["Zdenƒõk Burian","/wiki/Zden%C4%9Bk_Burian","1905‚1981"],
			["William Partridge Burpee","","1846‚1940"],
			["Brigitte Buscail-Lipsky","",""],
			["Ambreen Butt","/wiki/Ambreen_Butt",""],
			["Louis Buvelot","/wiki/Louis_Buvelot","1814‚1888"],
			["John Byrne","/wiki/John_Byrne",""],
			["Pogus Caesar","/wiki/Pogus_Caesar",""],
			["Cagnaccio di San Pietro","/wiki/Cagnaccio_di_San_Pietro","1897‚1946"],
			["Steven Campbell","/wiki/Steven_Campbell",""],
			["Canaletto","/wiki/Canaletto","1697‚1768"],
			["Noe Canjura","/wiki/Noe_Canjura","1922‚1970"],
			["Josef ƒåapek","/wiki/Josef_%C4%8Capek","1887‚1945"],
			["Tom Carapic","/wiki/Tom_Carapic",""],
			["Caravaggio","/wiki/Michelangelo_Merisi","1573‚1610"],
			["Ivan ƒåargo","","1898‚1958"],
			["Arthur B. Carles","/wiki/Arthur_B._Carles","1882‚1952"],
			["Carlo Carlone","/wiki/Carlo_Carlone","1686‚1775"],
			["John Fabian Carlson","","1875‚1945"],
			["Emile Auguste Carolus-Duran","/wiki/Emile_Auguste_Carolus-Duran","1838‚1917"],
			["Carpaccio","/wiki/Vittore_Carpaccio",""],
			["Oreste Carpi","/wiki/Oreste_Carpi",""],
			["Emily Carr","/wiki/Emily_Carr","1871‚1945"],
			["Carlo Carr√†","/wiki/Carlo_Carr%C3%A0","1881‚1966"],
			["Annibale Carracci","/wiki/Annibale_Carracci","1557‚1602"],
			["Agostino Carracci","/wiki/Agostino_Carracci","1560‚1609"],
			["Ludovico Carracci","/wiki/Ludovico_Carracci","1555‚1619"],
			["Clarence Holbrook Carter","/wiki/Clarence_Holbrook_Carter","1904‚2000"],
			["Ramon Casas i Carb√≥","/wiki/Ramon_Casas_i_Carb%C3%B3","1866‚1932"],
			["Felice Casorati","/wiki/Felice_Casorati","1886‚1963"],
			["Frances Castle","/wiki/Frances_Castle",""],
			["Judy Cassab","/wiki/Judy_Cassab",""],
			["Mary Cassatt","/wiki/Mary_Cassatt","1844‚1926"],
			["Alfred Joseph Casson","/wiki/Alfred_Joseph_Casson","1898‚1992"],
			["Humberto Castro","/wiki/Humberto_Castro",""],
			["Carlos Catasse","/wiki/Carlos_Catasse",""],
			["George Catlin","/wiki/George_Catlin","1796‚1872"],
			["Louis de Caullery","/wiki/Louis_de_Caullery",""],
			["Giovanni Paolo Cavagna","/wiki/Giovanni_Paolo_Cavagna","1556‚1627"],
			["Bernardo Cavallino","/wiki/Bernardo_Cavallino","1622‚1654"],
			["Antonio Cavallucci","/wiki/Antonio_Cavallucci","1752‚1795"],
			["Mirabello di Antonio Cavalori","/wiki/Mirabello_Cavalori",""],
			["Avgust ƒåernigoj","/wiki/Avgust_%C4%8Cernigoj","1898‚1985"],
			["Bartolomeo Cesi","/wiki/Bartolomeo_Cesi","1556‚1629"],
			["Paul C√©zanne","/wiki/Paul_C%C3%A9zanne","1839‚1906"],
			["Marc Chagall","/wiki/Marc_Chagall","1887‚1985"],
			["Minerva J. Chapman","/wiki/Minerva_J._Chapman","1858 - 1947"],
			["Jean-Baptiste-Sim√©on Chardin","/wiki/Jean-Baptiste-Sim%C3%A9on_Chardin","1699‚1779"],
			["Gustavo Charif","/wiki/Gustavo_Charif",""],
			["Caroline Chariot-Dayez","/wiki/Caroline_Chariot-Dayez",""],
			["Michael Ray Charles","/wiki/Michael_Ray_Charles",""],
			["Nicolas Charlet","/wiki/Nicolas_Charlet","1792‚1845"],
			["William Merritt Chase","/wiki/William_Merritt_Chase","1849‚1916"],
			["Th√©odore Chass√©riau","/wiki/Th%C3%A9odore_Chass%C3%A9riau","1819‚1856"],
			["Russell Chatham","/wiki/Russell_Chatham",""],
			["Pierre Puvis de Chavannes","/wiki/Pierre_Puvis_de_Chavannes","1824‚1898"],
			["Jozef Che≈Çmonski","","1849‚1914"],
			["Jules Ch√©ret","/wiki/Jules_Ch%C3%A9ret","1836‚1932"],
			["Chen Chi","","1912‚2005"],
			["Ch√©n Ch√∫n","/wiki/Chen_Chun","1483‚1544"],
			["Billy Childish","/wiki/Billy_Childish",""],
			["Giorgio de Chirico","/wiki/Giorgio_de_Chirico","1888‚1978"],
			["Adam Chmielowski","/wiki/Adam_Chmielowski","1888‚1878"],
			["Daniel Chodowiecki","/wiki/Daniel_Chodowiecki","1726‚1801"],
			["Dan Christensen","/wiki/Dan_Christensen","1942‚2007"],
			["Anthony Christian","/wiki/Anthony_Christian",""],
			["Abdul Rehman Chughtai","/wiki/Abdul_Rehman_Chughtai","1899‚1975"],
			["Frederick Edwin Church","/wiki/Frederick_Edwin_Church","1826‚1900"],
			["Betty Churcher","/wiki/Betty_Churcher",""],
			["Peter Churcher","/wiki/Peter_Churcher",""],
			["Winston Churchill","/wiki/Winston_Churchill","1874‚1965"],
			["Leon Chwistek","/wiki/Leon_Chwistek","1884‚1937"],
			["Tomasz Ciecierski","",""],
			["Cimabue","/wiki/Cimabue","1240‚1302"],
			["Giovanni Battista Ciprione","",""],
			["Joze Ciuha","/wiki/Joze_Ciuha",""],
			["Franz Ci≈æek","/wiki/Franz_Ci%C5%BEek","1865‚1946"],
			["Edna Clarke Hall","","1879‚1979"],
			["Francesco Clemente","/wiki/Francesco_Clemente",""],
			["Francois Clouet","/wiki/Francois_Clouet","1510‚1572"],
			["Giorgio Giulio Clovio","/wiki/Juraj_Julije_Klovic","1498‚1578"],
			["Juan Fernando Cobo","/wiki/Juan_Fernando_Cobo",""],
			["Pieter Codde","/wiki/Pieter_Codde","1599‚1678"],
			["Charles Codman","/wiki/Charles_Codman","1800‚1842"],
			["Jon Coffelt","/wiki/Jon_Coffelt",""],
			["Henry James Cogle","","1875 - 1915"],
			["Nevin √áokay","/wiki/Nevin_%C3%87okay",""],
			["Thomas Cole","/wiki/Thomas_Cole","1801‚1948"],
			["Robert Colescott","/wiki/Robert_Colescott",""],
			["Evert Collier","/wiki/Evert_Collier","1640‚1707"],
			["John Collier","/wiki/John_Collier_(artist)","1850‚1934"],
			["Jacob Collins","/wiki/Jacob_Collins",""],
			["Jean Colombe","","1430‚1493"],
			["Charles Conder","/wiki/Charles_Conder","1868‚1909"],
			["Kevin Connor","/wiki/Kevin_Connor",""],
			["John Constable","/wiki/John_Constable","1776‚1837"],
			["Constant","/wiki/Constant_Nieuwenhuys","1920‚2005"],
			["Theo Constant√©","/wiki/Theo_Constant%C3%A9",""],
			["Cassius Marcellus Coolidge","/wiki/Cassius_Marcellus_Coolidge","1844‚1934"],
			["D. D. Coombs","","1850‚1938"],
			["Colin Campbell Cooper","/wiki/Colin_Campbell_Cooper","1856‚1937"],
			["John Singleton Copley","/wiki/John_Singleton_Copley","1737‚1815"],
			["Lovis Corinth","/wiki/Lovis_Corinth","1858‚1925"],
			["Corneille","/wiki/Guillaume_Cornelis_van_Beverloo",""],
			["Thomas Cornell","/wiki/Thomas_Cornell",""],
			["Jean-Baptiste Camille Corot","/wiki/Jean-Baptiste_Camille_Corot","1796‚1875"],
			["Correggio","/wiki/Antonio_da_Correggio","1489‚1534"],
			["Pietro da Cortona","/wiki/Pietro_da_Cortona","1596‚1669"],
			["Rossella Cosentino","",""],
			["Piero di Cosimo","/wiki/Piero_di_Cosimo","1462‚1521"],
			["Grace Cossington Smith","/wiki/Grace_Cossington_Smith","1892‚1984"],
			["Francesco del Cossa","/wiki/Francesco_del_Cossa",""],
			["Pierre Auguste Cot","/wiki/Pierre_Auguste_Cot","1837‚1883"],
			["Noel Counihan","/wiki/Noel_Counihan","1913‚1986"],
			["Gustave Courbet","/wiki/Gustave_Courbet","1819‚1877"],
			["Thomas Couture","/wiki/Thomas_Couture","1815‚1879"],
			["Francesco Cozza","/wiki/Francesco_Cozza","1605‚1682"],
			["Richard Cramer","",""],
			["Lucas Cranach the elder","/wiki/Lucas_Cranach_the_elder","1472‚1553"],
			["Lucas Cranach the younger","/wiki/Lucas_Cranach_the_younger","1515‚1586"],
			["Fred Cress","/wiki/Fred_Cress",""],
			["Vivian Crettol","",""],
			["Susan Crile","/wiki/Susan_Crile",""],
			["Carlo Crivelli","/wiki/Carlo_Crivelli","1435‚1495"],
			["Ivan Lackoviƒá Croata","/wiki/Ivan_Lackovi%C4%87_Croata",""],
			["Charles Crodel","/wiki/Charles_Crodel","1894‚1974"],
			["Ray Crooke","/wiki/Ray_Crooke",""],
			["Jean Crotti","/wiki/Jean_Crotti","1878‚1958"],
			["Thomas Crotty","",""],
			["Enzo Cucchi","/wiki/Enzo_Cucchi",""],
			["Aelbert Cuyp","/wiki/Aelbert_Cuyp","1620‚1691"],
			["Boleslaw Cybis","/wiki/Boleslaw_Cybis","1895‚1957"],
			["Jan Cybis","","1897‚1972"],
			["Jozef Czapski","/wiki/Jozef_Czapski","1896‚1993"],
			["Szymon Czechowicz","/wiki/Szymon_Czechowicz","1689‚1775"],
			["Alfons von Czibulka","/wiki/Alfons_von_Czibulka","1888‚1969"],
			["Tytus Czy≈ºewski","/wiki/Tytus_Czy%C5%BCewski","1880‚1945"],
			["Jean-Yves Couliou","/wiki/Jean-Yves_Couliou","1916‚1995"],
			["Richard Dadd","/wiki/Richard_Dadd","1817‚1886"],
			["Bernardo Daddi","/wiki/Bernardo_Daddi",""],
			["Michael Dahl","/wiki/Michael_Dahl","1659‚1743"],
			["Dai Jin","/wiki/Dai_Jin","1388‚1462"],
			["Dai Xi","/wiki/Dai_Xi","1801‚1860"],
			["Roy Dalgarno","/wiki/Roy_Dalgarno","1910‚2001"],
			["Salvador Dali","/wiki/Salvador_Dal%C3%AD","1904‚1989"],
			["Christen Dalsgaard","/wiki/Christen_Dalsgaard","1824‚1907"],
			["Thomas Aquinas Daly","/wiki/Thomas_Aquinas_Daly",""],
			["Claude Dambreville","",""],
			["Ken Danby","/wiki/Ken_Danby",""],
			["Nils von Dardel","/wiki/Nils_von_Dardel","1888‚1943"],
			["William Dargie","/wiki/William_Dargie","1912‚2003"],
			["Charles-Fran√ßois Daubigny","/wiki/Charles-Fran%C3%A7ois_Daubigny","1817‚1878"],
			["Honore Daumier","/wiki/Honor%C3%A9_Daumier","1808‚1879"],
			["Gerard David","/wiki/Gerard_David",""],
			["Jacques Louis David","/wiki/Jacques_Louis_David","1748‚1825"],
			["Heinrich Maria Davringhausen","/wiki/Heinrich_Maria_Davringhausen","1894‚1970"],
			["Janet Dawson","/wiki/Janet_Dawson",""],
			["Leonardo da Vinci","/wiki/Leonardo_da_Vinci","1452‚1519"],
			["Gene Davis","/wiki/Gene_Davis_(painter)","1920‚1985"],
			["Ronald Davis","/wiki/Ronald_Davis",""],
			["Stuart Davis","/wiki/Stuart_Davis_(painter)","1892‚1964"],
			["Riko Debenjak","",""],
			["Jean Baptiste Debret","/wiki/Jean_Baptiste_Debret","1768 - 1848"],
			["Stanislaw Debicki","","1866‚1924"],
			["Christian De Calvairac","",""],
			["Joseph DeCamp","/wiki/Joseph_DeCamp","1858‚1923"],
			["Michel De Caso","/wiki/Michel_De_Caso",""],
			["Edgar Degas","/wiki/Edgar_Degas","1834‚1917"],
			["Ettore DeGrazia","/wiki/Ettore_DeGrazia","1909‚1982"],
			["Raoul De Keyser","/wiki/Raoul_De_Keyser",""],
			["Eug√®ne Delacroix","/wiki/Eug%C3%A8ne_Delacroix","1798‚1863"]
			]
		cts.each_with_index do |ct,i|
			
				
				t = Tag.new(:label => ct[0], :kind => 'person', :data => "#wikipedia_url #{ct[1]} #dates #{ct[2]} ")
				
				unless ct[1].blank?
					wiki_content = Nuniverse.get_description_from_wikipedia(ct[1])
						dc = (wiki_content/:p).first
						(dc/:sup).remove
						(dc/:span).remove
						(dc/:br).remove
						(dc/:p).each do |a|
							a.swap(a.inner_html)
						end
						(dc/:a).each do |a|
							a.swap(a.inner_html)
						end
						(dc/:b).each do |a|
							a.swap(a.inner_html)
						end
						(dc/:i).each do |a|
							a.swap(a.inner_html)
						end
						t.description = dc.to_s
						t.save
						img = (wiki_content/'table.infobox'/:img).first
						unless img.nil? || img.to_s.match(/Replace_this_image|Flag_of/)
							t.add_image(:source_url => img.attributes['src'])
						end
				else
					t.save
				end
				
				 Tagging.create(:subject_id => 0, :object_id => t.id, :user_id => 0, :kind => 'person', :public => 1)
				 Tagging.create(:subject_id => 0, :object_id => t.id, :user_id => 0, :kind => 'painter', :public => 1)
				# t = "/wiki/#{ct.label.titleize.gsub(' ','_')}"
				# 			
				# 			
				# 			begin
				# 				begin
				# 					w = Nuniverse.get_description_from_wikipedia("#{t}_(Film)")
				# 					raise false if (w/'#noarticletext')
				# 				rescue
				# 					w = Nuniverse.get_description_from_wikipedia("#{t}_(film)")
				# 					raise false if (w/'#noarticletext')
				# 				end
				# 			rescue
				# 				w = Nuniverse.get_description_from_wikipedia("#{t}")
				# 			end
				# 			
				# 			if w
				# 				img = (w/'table.infobox'/:img).first
				# 				unless img.nil? || img.to_s.match(/Replace_this_image|Flag_of/)
				# 					ct.add_image(:source_url => img.attributes['src'].gsub('thumb/',''))
				# 				end
				# 			end
		# end
		# dc = Hpricot(ct.description)
		# 
		# 	ct.description = dc.to_s
		# ct.save
	end
	end
	
	def batch

		if params[:batch]
			@batch = params[:batch].split(",")
			@batch.each do |item|
				t = Tag.new(:label => item, :kind => params[:kind])
				t.save
				Tagging.create(:subject_id => 0, :object_id => t.id, :user_id => 0, :kind => t.kind, :public => 1)
			end	
			@batch = ""
			flash[:notice] = "batch is a done deal."
		end
		
	end
	
	def test
		@wiki_url = "/wiki/Tengiz_Abuladze"
	end
end

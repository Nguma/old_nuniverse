jQuery.fn.addColorPicker = function( props ) {
	if( ! props ) { props = []; }
	props = jQuery.extend({
		colors : ["#000000","#000033","#000066","#000099","#0000CC","#0000FF","#330000","#330033","#330066","#330099","#3300CC",
		"#3300FF","#660000","#660033","#660066","#660099","#6600CC","#6600FF","#990000","#990033","#990066","#990099",
		"#9900CC","#9900FF","#CC0000","#CC0033","#CC0066","#CC0099","#CC00CC","#CC00FF","#FF0000","#FF0033","#FF0066",
		"#FF0099","#FF00CC","#FF00FF","#003300","#003333","#003366","#003399","#0033CC","#0033FF","#333300","#333333",
		"#333366","#333399","#3333CC","#3333FF","#663300","#663333","#663366","#663399","#6633CC","#6633FF","#993300",
		"#993333","#993366","#993399","#9933CC","#9933FF","#CC3300","#CC3333","#CC3366","#CC3399","#CC33CC","#CC33FF",
		"#FF3300","#FF3333","#FF3366","#FF3399","#FF33CC","#FF33FF","#006600","#006633","#006666","#006699","#0066CC",
		"#0066FF","#336600","#336633","#336666","#336699","#3366CC","#3366FF","#666600","#666633","#666666","#666699",
		"#6666CC","#6666FF","#996600","#996633","#996666","#996699","#9966CC","#9966FF","#CC6600","#CC6633","#CC6666",
		"#CC6699","#CC66CC","#CC66FF","#FF6600","#FF6633","#FF6666","#FF6699","#FF66CC","#FF66FF","#009900","#009933",
		"#009966","#009999","#0099CC","#0099FF","#339900","#339933","#339966","#339999","#3399CC","#3399FF","#669900",
		"#669933","#669966","#669999","#6699CC","#6699FF","#999900","#999933","#999966","#999999","#9999CC","#9999FF",
		"#CC9900","#CC9933","#CC9966","#CC9999","#CC99CC","#CC99FF","#FF9900","#FF9933","#FF9966","#FF9999","#FF99CC",
		"#FF99FF","#00CC00","#00CC33","#00CC66","#00CC99","#00CCCC","#00CCFF","#33CC00","#33CC33","#33CC66","#33CC99",
		"#33CCCC","#33CCFF","#66CC00","#66CC33","#66CC66","#66CC99","#66CCCC","#66CCFF","#99CC00","#99CC33","#99CC66",
		"#99CC99","#99CCCC","#99CCFF","#CCCC00","#CCCC33","#CCCC66","#CCCC99","#CCCCCC","#CCCCFF","#FFCC00","#FFCC33",
		"#FFCC66","#FFCC99","#FFCCCC","#FFCCFF","#00FF00","#00FF33","#00FF66","#00FF99","#00FFCC","#00FFFF","#33FF00",
		"#33FF33","#33FF66","#33FF99","#33FFCC","#33FFFF","#66FF00","#66FF33","#66FF66","#66FF99","#66FFCC","#66FFFF",
		"#99FF00","#99FF33","#99FF66","#99FF99","#99FFCC","#99FFFF","#CCFF00","#CCFF33","#CCFF66","#CCFF99","#CCFFCC",
		"#CCFFFF","#FFFF00","#FFFF33","#FFFF66","#FFFF99","#FFFFCC","#FFFFFF"],
		width : '36',
		autoClose: 'yes',
		colorBg: 'yes',
		showCode: 'yes',
		cursor: 'crosshair',
		bgColor: '#000000',
		closeText: 'Close',
		callback: ''
	}, props);	
	
	function RGBToHex(value) 
	{
	    var re = /\d+/g;
	    var matches = value.match(re);
	    for( var i = 0; i < matches.length; i++ ) {
	        matches[i] = parseInt(matches[i]).toString(16);
	        if( matches[i].length < 2 ) matches[i] = '0'+matches[i];
	    }
	    
		return "#" + matches[0] + matches[1] + matches[2];
	}



	$(this).click(
		function() 
		{ 
			var total = props.colors.length;
			var elem = jQuery('<div id="col_container"></div>').hide().css({"border-color":"#000000", "border-style":"solid", "border-width":"1px"}).html("");
			elem.css({'cursor':props.cursor});
			elem.css({'background-color':props.bgColor});
	
			var $current = $(this);

			for(i=0;i<total;i++)
			{
				if((i%props.width) == 0)
				{
					if(i > 0)
					{
						elem.append('<br />');
					}
				}
				
				var $box = jQuery("<span style='background-color:"+props.colors[i]+"; class='all_colors'>&nbsp;</span>");
				$box.appendTo(elem);	
				
				$box.click(function(){
					var c = $(this).css("background-color");

					if( c.indexOf('rgb') !=-1 )
					{
						var color = RGBToHex(c);
					}
					else
					{
						color = c;
					}

					if( props.colorBg == 'yes')
					{
						$current.css({'background-color':color});
					}
					
					if( props.showCode == 'yes')
					{
						$current.val(color);
					}
					
					if(props.autoClose == 'yes')
					{
						elem.hide();
					}
					
					if(props.callback)
					{
						props.callback(color);
					}
				});		

				$box.mouseover(function(){
					var c = $(this).css("background-color");

					if( c.indexOf('rgb') !=-1 )
					{
						var color = RGBToHex(c);
					}
					else
					{
						color = c;
					}

					if( props.colorBg == 'yes')
					{
						$current.css({'background-color':color});
					}
					
					if( props.showCode == 'yes')
					{
						$current.val(color);
					}
					
					if(props.callback)
					{
						props.callback(color);
					}
					
				});

			}		
		elem.insertAfter($(this));
			
			position = $(this).offset();
			n_top = position.top;
			n_left = position.left;
			n_width = $(this).width();

			elem.css({"position":"absolute", "top":n_top-20, "left":n_width+n_left});
			elem.show();
			
			if(props.autoClose !== 'yes')
			{
				var $closeLink = jQuery("<br /> <a href='#' id='link_close'>"+props.closeText+"</a>");	
				$closeLink.appendTo(elem);
				$closeLink.click(function(){
					elem.hide();
				});
			}			
		}
	);

	return this;
};
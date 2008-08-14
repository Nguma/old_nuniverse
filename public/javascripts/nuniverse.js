var Nuniverse = new Class({
  Implements: Options,
  options:{
    form:null,
    nav:null,
    focus:null,
    map:{}
  },
  
  initialize:function()
  {
    this.el = $('nuniverse');
    
    if(!$defined(this.el)) {return }
    
    this.slide = new Fx.Scroll(this.getScroller(), {
      'offset':{'x':-300,'y':0}
    });
    this.selectSection(this.el.getElement('.current_section'));
    var obj = this;
    // $('main_menu').getElements('a').each(function(action)
    //     {
    //       action.addEvent('click', function(ev)
    //       {
    //         ev.preventDefault();
    //         obj.request(action.getProperty('href'), obj.currentSection(), 'section');
    //         return false;
    //       },this);
    //     },this);
    
    window.document.addEvent('keypress',this.onKey.bindWithEvent(this));
    var obj = this;
    this.setConnectionForm();
    this.setDropdown();
    this.finder =  new Finder($('finder'));
    this.finder.addEvents({
      'connect':function(a,b,c,d)
        {
          obj.currentSection().getElement('.connections').grab(a[0],'top');
          obj.currentSection().getElement('.article').addClass('hidden');
        }
      },this);
  },
  
  onKey:function(ev)
  {
   
    switch(ev.key)
    {
        case "up":
          this.selectConnection(ev,this.listSection().getElement(".connections .selected").getPrevious("dd"));
          break;
        case "down":
          this.selectConnection(ev,this.listSection().getElement(".connections .selected").getNext("dd"));
          break;
        case "left":
          this.selectSection(this.listSection());
          break;
        case "right":
          break;
        case "enter":
          break;
        case "space":
          if(this.options['focus'] == null)
          {
            this.finder.expand();
          }
          
          break;
        default:
          //this.finder.expand(ev.key);
          
    }
  },
  
  setFocus:function(el)
  {
    console.log(el)
    el.focus();
    this.options['focus'] = el; 
  },
  
  removeFocus:function(el)
  {
    if(this.options['focus'] == el)
    {
      this.options['focus'] = null;
    }
  },
  
  getFocus:function()
  {
    return this.options['focus'];
  },
  
  getScroller:function()
  {
    return this.el.getElement('.scroller');
  },
  
  nextSection:function(section)
  {
    var section = section || this.currentSection();
    if($defined(section.getNext('.section')))
    {
      return section.getNext('.section');
    }
    else
    {
      return new Element('div',{
        'class':'section'
      }).inject(section, 'after');
      
    }
  },
  
  currentSection:function()
  {
    return this.el.getElement('.current_section');
   // return this.options['section']
  },
  
  listSection:function()
  {
    return this.currentSection().getPrevious('.section');
  },
  
  setDropdown:function(section)
  {
    var obj = this;
    if(!$defined(this.el.getElement('.dropdown'))) return;
    this.dropdown = new Dropdown(this.el.getElement('.dropdown'),{
      onChange:function(service)
      {
        obj.changeService(service);
      }
    },this);
  },
  
  changeService:function(service_call)
  {
    this.request(service_call+'&path='+this.currentPath(), this.currentSection());
  },
  
  setConnections:function(root)
  {
    root.getElements('.connection').each(function(connection)
    {
      connection.removeEvents();
      connection.getElements('a.bookmark').each(function(action)
      {
        action.removeEvents();
        action.addEvent('click', this.bookmark.bindWithEvent(this,[connection, action]));
      },this);
        
      connection.addEvents(
      {
          'mouseenter':function() {connection.addClass('hover');},
          'mouseleave':function() {connection.removeClass('hover');},
          'mousedown':this.scrollContent.bindWithEvent(this,connection),
          'mouseup':this.stopScrollingContent.bind(this,connection),
          'click':this.selectConnection.bindWithEvent(this,connection)
      },this);
      
      
     
      
      connection.getElements('a.remove').each(function(action)
      { 
        action.removeEvents();
        action.addEvent('click', this.removeBookmark.bindWithEvent(this,[connection, action]));
      },this);
      
      connection.getElement('h3 a').addEvent('click', this.selectConnection.bindWithEvent(this,connection));

    },this);
  
    
  },
  
  bookmark:function(ev, connection, action)
  {
    ev.stopPropagation();
    ev.preventDefault();
    var form = connection.getElement('.data form');
    var call = new Request.HTML(
        {
          'url':action.getProperty('href'),
          'onSuccess':function()
          {
            notice("Bookmarked!");
            connection.getElement('a.bookmark').destroy();
          }
    }).post(form);
    return false;
  },
  
  removeBookmark:function(ev, connection, action)
  {
    ev.preventDefault();
    var form = connection.getElement('.data form');
    var call = new Request.HTML(
    {
      'url':action.getProperty('href'),
      'data':{'_method':'delete'},
      'onSuccess':function()
      {
        connection.destroy();
      }
    }).post(form);
    return false;
  },
  
  scrollContent:function(ev,connection)
  {
   
    this.isScrolling = false;
    var obj = this;
    var section = connection.getParent('.content');
    var y = ev.page.y+section.getScroll().y;
    section.addEvent('mousemove',function(ev)
    {
      if(Math.abs(y - ev.page.y) > 1)
      {
        
        section.scrollTo(section.getPosition().x,y - ev.page.y);
        obj.setScrollFlag(true);
      }
      
    },this);
  },
  
  setScrollFlag:function(bool)
  {
    this.isScrolling = bool;
  },
  
  stopScrollingContent:function(connection)
  {
    var section = connection.getParent('.content');
    section.removeEvents();
    this.setScrollFlag.delay(100,true);
  },
  
  selectConnection:function(ev, connection)
  {
    ev.preventDefault();
    var atag = connection.getElement('h3 a');
    if(this.isScrolling) return false;
    if(this.getConnectionType(connection) == "inner") 
    {
      this.request(connection.getElement('h3 a').getProperty('href'),this.nextSection(connection.getParent('.section')))
      // $try(function(){
      //         // connection.getParent('.connections').getElement('.selected').getElement('menu').destroy() 
      //       },this);
      //       connection.adopt(this.el.getElement('.menu').clone());
    } 
    else {
      window.open(atag.getProperty('href'), '_blank');
    }
    this.setSelected(atag.getParent('dd'),connection.getParent('.connections'));
  },
  
  getConnectionType:function(connection)
  {
    if(connection.getElement('h3 a').hasClass('inner'))
    {
      return "inner"
    }
    return "outer"
  },
  
  getForm:function()
  {
    return this.options['section'].getElement('.new_connection');
  },

  setSelected:function(el,context)
  {
    var previous = context.getElement('.selected');
    if($defined(previous))
    {
      previous.removeClass('selected');
    }
    el.addClass('selected');
  },
  
  request:function(url,target)
  {
    var params = params || ""
    var obj = this;
    var type = type || "update";
    target.empty();
    target.adopt($('spinner').clone());    
    var args = {
      'url':url,
      'autoCancel':true,
      'evalScripts':true,
      
      'onSuccess':function(a,b,c,d)
      {  
        target.empty();
        obj.selectSection(target.adopt(a[0].getChildren())); 
        
        // target.empty();
        //        if(!$defined(u) || u == ".section")
        //        {
        //          
        //        } 
        //        else
        //        {
        //          
        //          obj.refresh(target.adopt(a[0].getElement(u).getChildren()));
        //          
        //        } 
      }
    }  
    var call = new Request.HTML(args).get();
  },
  
  setConnectionForm:function(section)
  {
    var obj = this;
    var form = this.el.getElement('.new_connection');
    if($defined(form))
    {
      this.options['form'] = new NForm(form);
      this.options['form'].addEvents(
        {
          'success':function(a,b,c,d)
          {
            var updated = this.currentSection().getElement('.connections');
            updated.grab(a[0],'top');
            obj.setConnections(updated);
            notice("New connection added.")
          },
          'suggest':function(suggestions)
          {
            suggestions.getChildren().each(function(suggestion)
            {
              suggestion.addEvent('click', function(ev)
              {
                ev.preventDefault();
                ev.stopPropagation();
                form.getElement('input#label').setProperty('value', suggestion.getElement('h4').get('text'));
                form.getElement('input#kind').setProperty('value', suggestion.getElement('p').get('text'));
                obj.options['form'].submit(ev);
              });
            });
          }
        });
    }
    
  },
  
  breadcrumbs:function()
  {
    return $('breadcrumbs');
  },
  
  setHat:function(section)
  {
   if($defined($('breadcrumbs')))
   {
     $('breadcrumbs').getElements('dd').each(function(el)
     {
       el.destroy();
     });
     var crumbs = this.el.getElements('.section h2 a');
     crumbs.pop();
     crumbs.each(function(crumb,i)
     {
       var c = new Element('dd',
       {
         styles:{
           'z-index':999-i,
           'left': -(30 * (i+1))+'px'
         }
       });
       $('breadcrumbs').adopt(c.adopt(crumb.clone()));
       c.addEvent('click', function(ev)
       {
         var section = obj.el.getElements(".section")[i];
         obj.selectSection(section);
       });
     });
   }   
    this.setBackButton(section);
  },
  
  setBackButton:function(section)
  {
    var back_button = this.el.getElement('.back');
    if(!$defined(back_button)) return;
    if(!$defined(this.listSection()))
    {
      back_button.setStyle('display','none');
    }
    else
    {
      back_button.setStyle('display','block');
      back_button.removeEvents();
      back_button.addEvent('click', this.back.bind(this));
    }
  },
  
  back:function()
  {
    this.selectSection(this.listSection());
  },
  
  selectSection:function(section)
  {
    
    if(!$defined(this.currentSection()))
    {
      this.options['section'] = section;
      this.currentSection().addClass('current_section');
      this.refresh(section);
    } 
   
    if(section == this.currentSection()) 
    {
      this.refresh(section);
      return;
    }
    
    if($defined(this.options['form']))
    {
      this.options['form'].collapse();
       if($defined(section.getElement('.new_connection')))
        {
          this.options['form'].el = section.getElement('.new_connection');
        }
      
    }
   
    this.currentSection().removeClass('current_section');
    this.options['section'] = section;
    
    section.addClass('current_section');
    section.getAllNext('.section').destroy();
    this.slide.toElement(this.currentSection());
    
    this.refresh(section);
    
  },
  
  refresh:function(section)
  {
    
    this.setHat(section);
    this.setSection(section);
    if(section.getElement('.map'))
    {
      this.setMap();
    }
    
  },
  
  setSection:function(section)
  {
    this.setWidgets(); 
    this.enableScroll(section);
    this.setConnections(section);
    //this.setConnectionForm(section);
    this.currentSection().getElements('form').each(function(form)
    {
      var f = new NForm(form);
      f.addEvents({
        'focus':this.setFocus.bind(this, form),
        'blur':this.removeFocus.bind(this, form)
      },this);
    },this);

  },
  
  
  enableScroll:function(section)
  {
    var slider = section.getElement('.slider');
    if(!$defined(slider)) return;
    section.removeEvents();
    var sliding = new Slider(slider, slider.getElement('.knob'),
    {
      onChange:function(step)
      {
        
      }
    });
  },
  
  sectionService:function(section)
  {
    if ($defined(section.getElement('.service')))
    {
      return section.getElement('.service').get('text')
    }
    return null
  },
  
  setMap:function()
  {
    //section = params['section'];
    if($defined(this.map) )
    {
      this.map = null;
    }
    params = this.options['map']
    var map_div = $('map_div');//section.getElement('.map');
    if($defined(map_div))
    {
     
      if (GBrowserIsCompatible()) {
       
       this.map = new GMap2(map_div);
       
       
       this.map.setCenter(new GLatLng(params['center']['latitude'],params['center']['longitude']),params['zoom']);
       this.map.addControl(new GLargeMapControl());
       //this.map.addControl(new GMapTypeControl());
      // this.map.addControl(new google.maps.LocalSearch());
       //this.map.addControl( new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(10,20)));
       //console.log(params['markers'])
       params['markers'].each(function(m)
       {
         
         var marker = new GMarker(new GLatLng(m['latitude'],m['longitude']), {title:m['title'], draggable:true});
         
         this.map.addOverlay(marker);
         GEvent.addListener(marker, "click", function() {
             marker.openInfoWindowHtml("<h2 style='color:#333'>"+m['title']+"</h2>");
           });
         
       },this);
       }
       
    } 
  },
  
  destroySection:function(section)
  {
    section.getElements()
  },
  
  setWidgets:function()
  {
    $$('div.widget .elements').each(function(widget)
     {
       var sc = new Fx.Scroll(widget);
       widget.addEvent('click', function(ev)
       {
         var current = widget.getElement('.selected');
         var next = current.getNext('.element');
         if(!$defined(next))
         {
           next = widget.getElement('.element');
         }
         current.removeClass('selected');
         next.addClass('selected');
         sc.toElement(next);
       });
     });
  },
  
  currentPath:function()
  {
    return this.currentSection().getElement('.path').get('text');
  }
});
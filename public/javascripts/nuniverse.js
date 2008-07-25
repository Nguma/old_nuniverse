var Nuniverse = new Class({
  Implements: Options,
  options:{
    form:null,
    nav:null,
    map:{}
  },
  
  initialize:function()
  {
    this.el = $('nuniverse');
    if(!$defined(this.el)) {return }
    
    this.slide = new Fx.Scroll(this.getScroller(), {
      'offset':{'x':-310,'y':0}
    });
    this.selectSection(this.el.getElement('.current_section'));
    var obj = this;
    $('main_menu').getElements('a').each(function(action)
    {
      action.addEvent('click', function(ev)
      {
        ev.preventDefault();
        obj.requestAndReplace(action.getProperty('href'), obj.currentSection());
        return false;
      },this);
    },this);
    
    window.document.addEvent('keypress',this.onKey.bindWithEvent(this));
    
   
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
        
        default:
    }
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
  
  setPerspectives:function(section)
  {
    var obj = this;
    var dropdown = section.getElement('.menu dl');
    if(!$defined(dropdown)) return;
    dropdown.getElements('dd').each(function(action)
    {
       action.addEvents({
        'click':function(ev)
          {
            if(!action.hasClass('selected'))
            {
              obj.setSelected('dd','dl',this.getElement('a'));
              if(dropdown.hasClass('perspective'))
              {
                dropdown.getElement('dt').set('text', 'According to '+action.get('text').toLowerCase());
              }
              else
              {
                dropdown.getElement('dt').set('text', 'Sorted '+action.get('text').toLowerCase());
              }
              
              var updated = section.getElement('.content');
              updated.set('html', '<h6>Loading...</h6>');
              dropdown.removeClass('expanded');
              obj.requestAndUpdate(this.getElement('a').get('href'),updated);
              
            } 
            else
            {
              dropdown.addClass('expanded')
            }
            return false;
          },
        'mouseenter':function(){action.addClass('hover')},
        'mouseleave':function(){action.removeClass('hover')}   
       });
       
       action.getElement('a').addEvent('click', function(){return false;})
       
      });
       
      dropdown.addEvents({
        'click':function(ev){
          if(!this.hasClass('expanded'))
          {
            this.addClass('expanded');
            // var label = dropdown.getElement('dt').get('text');
            //            label.gsub(this.getElement('.selected a').get('text'),"").rstrip
            //            dropdown.getElement('dt').set('text',label);
          }
        },
        'mouseleave':function(ev){
          this.removeClass('expanded');
          var label = "According to "+ this.getElement('.selected a').get('text').toLowerCase()
          dropdown.getElement('dt').set('text',label);
        }
      });
  },
  
  setConnections:function(root)
  {
    root.getElements('.connection').each(function(connection)
    {
      connection.removeEvents();
      connection.addEvents(
      {
          'mouseenter':function() {connection.addClass('hover');},
          'mouseleave':function() {connection.removeClass('hover');},
          'mousedown':this.scrollContent.bindWithEvent(this,connection),
          'mouseup':this.stopScrollingContent.bind(this,connection),
          'click':this.selectConnection.bindWithEvent(this,connection)
      },this);
      
      connection.getElements('a.bookmark').each(function(action)
      {
        action.addEvent('click', this.bookmark.bindWithEvent(this,[connection, action]));
      },this);
      
      connection.getElements('a.remove').each(function(action)
      {
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
    var section = connection.getParent('.section');
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
    var section = connection.getParent('.section');
    section.removeEvents();
    this.setScrollFlag.delay(100,true);
  },
  
  selectConnection:function(ev, connection)
  {
    ev.preventDefault();
    if(this.isScrolling) return false;
    var atag = connection.getElement('h3 a');
    
    var section = this.nextSection(connection.getParent('.section'));
    
    section.getChildren().destroy();
    if(this.getConnectionType(connection) == "inner") 
    {
      this.requestAndReplace(atag.getProperty('href'), section);
    }
    else 
    {
      window.open(atag.getProperty('href'), '_blank');
      
    }
    this.setSelected('dd','dl',atag);
    // connection.getElements('.manage a').each(function(action)
    //     {
    //       action.addEvent('click',function(ev)
    //       {
    //         var form = connection.getElement('.data form')
    //         var submission = new Request.HTML({
    //           'url':form.getProperty('action'),
    //           onSuccess:function(a,b,c,d)
    //           {
    //             
    //           }
    //         }).post(form);
    //         return false;
    //       });
    //     });
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
  
  update:function(updated,content)
  {
    updated.set('html', content);
    this.setConnections(updated);
    this.setConnectionForm();
  },
  
  perspectives:function()
  {
    return this.currentSection().getElement('.perspectives');
  },
  
  getFilters:function()
  {
    return $$('.filters dd a');
  },
  
  setSelected:function(el,context,activator)
  {
    var previous = activator.getParent(context).getElement('.selected');
    if($defined(previous))
    {
      previous.removeClass('selected');
    }
    activator.getParent(el).addClass('selected');
  },
  
  requestAndReplace:function(url,replaced, params )
  {
    var params = params || ""
    this.ajaxRequest(url,replaced, "replace", params);
  },
  
  requestAndUpdate:function(url, updated, params)
  {
    var params = params || null
    this.ajaxRequest(url,updated, "update", params);
  },
  
  ajaxRequest:function(url,target,type, params)
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
        if(type == "replace")
        {
          var new_section = a[0].replaces(target);
        }
        else
        {
          target.empty();
          var new_section = target.adopt(a[0])
        }
        if(target.hasClass('section'))
        {
           obj.selectSection(new_section);
        }
        else
        {
          obj.refresh(new_section);
        }
        
        
        if(new_section.getElement('.map'))
        {
          obj.setMap();
        }
      }
    }  
    var call = new Request.HTML(args).get();
  },
  
  setConnectionForm:function(section)
  {
    var obj = this;
    var form = section.getElement('.new_connection')
    if($defined(form))
    {
      this.options['form'] = new NForm(form);
      this.options['form'].addEvent('success',function(a,b,c,d)
      {
        var updated = section.getElement('.content .connections');
        updated.grab(a[0],'top');
        obj.setConnections(updated);
      });
    }
    
  },
  
  breadcrumbs:function()
  {
    return $('breadcrumbs');
  },
  
  setHat:function()
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
    
    var back_button = this.currentSection().getElement('.back')
    if($defined(back_button))
    {  
       back_button.addEvent('click', this.selectSection.bind(this, back_button.getParent('.section')));
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
    this.setPerspectives(section);
    this.setConnections(section);
    this.setConnectionForm(section);
    this.setWidgets();
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
       // this.map.addControl(new GMapTypeControl());
       this.map.addControl(new google.maps.LocalSearch(), new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(10,20)));
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
  }
});
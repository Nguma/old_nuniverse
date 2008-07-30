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
        obj.request(action.getProperty('href'), obj.currentSection());
        return false;
      },this);
    },this);
    
    window.document.addEvent('keypress',this.onKey.bindWithEvent(this));
    this.setConnectionForm();
   
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
  
  setDropdowns:function(section)
  {
    var dropdowns = this.el.getElements('.dropdown');
    dropdowns.each(function(dropdown)
    {
      dropdown.removeEvents();
      dropdown.getElements('dd').each(function(option)
      {
        option.removeEvents();
        option.addEvents({
          'click':this.selectFromDropdown.bindWithEvent(this, [dropdown, option]),
          'mouseenter':function() {option.addClass('hover');},
          'mouseleave':function() {option.removeClass('hover');},
          
        },this);
      },this);
      dropdown.addEvents({
        'mouseleave':this.collapseDropdown.bind(this, dropdown),
        'click':this.expandDropdown.bind(this, dropdown)
      },this);
    },this);
  },
  
  selectFromDropdown:function(ev,dropdown,option)
  {
    ev.preventDefault();
    this.setSelected(option,dropdown);
    this.collapseDropdown(dropdown);
    this.request(option.getElement('a').getProperty('href'),this.currentSection().getElement('.content'));
    return false;
  },
  
  expandDropdown:function(dropdown)
  {
    dropdown.addClass('expanded');
    // dropdown.getElement('dt .label').set('text', ':');
  },
  
  collapseDropdown:function(dropdown)
  {
    if(dropdown.hasClass('expanded'))
    {
      dropdown.removeClass('expanded');
      dropdown.getElement('dt .label').set('text', dropdown.getElement('.selected').get('text').toLowerCase());      
    }
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
      this.loadContent(this.nextSection(connection.getParent('.section')), connection.getElement('h3 a').getProperty('href'))
    } 
    else {
      window.open(atag.getProperty('href'), '_blank');
    }
    this.setSelected(atag.getParent('dd'),connection.getParent('.connections'));
  },
  
  loadContent:function(section, source)
  {
    section.getChildren().destroy();
    this.request(source, section);
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
  
  // update:function(updated,content)
  //  {
  //    updated.set('html', content);
  //    this.setConnections(updated);
  //    this.setConnectionForm();
  //  },
  
  perspectives:function()
  {
    return this.currentSection().getElement('.perspectives');
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
        if(target.hasClass('section'))
        {
          obj.selectSection(target.adopt(a[0].getChildren()));
        } 
        else
        {
          obj.refresh(target.adopt(a[0].getElement('.content').getChildren()));
        } 
      }
    }  
    var call = new Request.HTML(args).get();
  },
  
  setConnectionForm:function(section)
  {
    var obj = this;
    var form = this.el.getElement('.new_connection');
    console.log(form);
    if($defined(form))
    {
      this.options['form'] = new NForm(form);
      this.options['form'].addEvents(
        {
          'success':function(a,b,c,d)
          {
            var updated = this.currentSection().getElement('.content .connections');
            updated.grab(a[0],'top');
            obj.setConnections(updated);
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
                form.submit(ev);
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
    if(this.listSection() == this.el.getElement('.section'))
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
    this.setDropdowns(section);
    if(section.getElement('.map'))
    {
      this.setMap();
    }
    
  },
  
  setSection:function(section)
  {
    switch(this.sectionService(section))
    {
      case "article":
        this.enableScroll(section);
        break;
      case "connections":
        this.setConnections(section);
        
        break;
      case "overview":
        
        break;
      default:
        this.setWidgets(); 
        this.enableScroll(section);
        this.setConnections(section);
        
    }
    
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
        console.log(step);
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
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
    this.slide = new Fx.Scroll(this.getScroller());
    this.selectPage(this.el.getElement('.current_page'));
    this.refresh(this.nextPage());
  },
  
  getScroller:function()
  {
    return this.el.getElement('.scroller');
  },
  
  nextPage:function()
  {
    if($defined(this.currentPage().getNext('.page')))
    {
      return this.currentPage().getNext('.page')
    }
    else
    {
      return new Element('div',{
        'class':'page'
      }).inject(this.currentPage(), 'after');
      
    }
  },
  
  currentPage:function()
  {
    // return this.el.getElement('div.selected');
    return this.options['page']
  },
  
  setPerspectives:function(page)
  {
    var obj = this;
    var perspectives = page.getElement('.perspectives');
    if(!$defined(perspectives)) return;
    perspectives.getElements('dd').each(function(action)
    {
       action.addEvents({
        'click':function(ev)
          {
            if(!action.hasClass('selected'))
            {
              obj.setSelected('dd','dl',this.getElement('a'));
              perspectives.getElement('dt').set('text', 'According to '+action.get('text').toLowerCase());
              var updated = page.getElement('.content');
              updated.set('html', '<h6>Loading...</h6>');
              perspectives.removeClass('expanded');
              obj.requestAndUpdate(this.getElement('a').get('href'),updated);
              
            } 
            else
            {
              perspectives.addClass('expanded')
            }
            return false;
          },
        'mouseenter':function(){action.addClass('hover')},
        'mouseleave':function(){action.removeClass('hover')}   
       });
       
       action.getElement('a').addEvent('click', function(){return false;})
       
      });
       
      perspectives.addEvents({
        'click':function(ev){
          if(!this.hasClass('expanded'))
          {
            this.addClass('expanded');
            perspectives.getElement('dt').set('text', 'According to: ');
          }
        },
        'mouseleave':function(ev){
          this.removeClass('expanded');
          perspectives.getElement('dt').set('text', 'According to '+this.getElement('.selected a').get('text').toLowerCase());
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
          'click':this.selectConnection.bind(this,connection)
      },this);
    },this);
  },
  
  scrollContent:function(ev,connection)
  {
   
    this.isScrolling = false;
    var obj = this;
    var page = connection.getParent('.page');
    var y = ev.page.y+page.getScroll().y;
    page.addEvent('mousemove',function(ev)
    {
      if(Math.abs(y - ev.page.y) > 1)
      {
        
        page.scrollTo(page.getPosition().x,y - ev.page.y);
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
    var page = connection.getParent('.page');
    page.removeEvents();
    this.setScrollFlag.delay(100,true);
    console.log(this)
  },
  
  selectConnection:function(connection)
  {
    if(this.isScrolling) return false;
    var atag = connection.getElement('a.main');
    this.setSelected('dd','dl',atag);
    this.selectPage(connection.getParent('.page'));
    this.nextPage().getChildren().destroy();
    if(this.getConnectionType(connection) == "inner") 
    {
      this.requestAndReplace(connection.getElement('.path').get('text'), this.nextPage());
    }
    else
    {
      window.open(atag.getProperty('href'), '_blank');
    }
    connection.getElements('.manage a').each(function(action)
    {
      action.addEvent('click',function(ev)
      {
        var form = connection.getElement('.data form')
        var submission = new Request.HTML({
          'url':form.getProperty('action'),
          onSuccess:function(a,b,c,d)
          {
            
          }
        }).post(form);
        return false;
      });
    });
  },
  
  getConnectionType:function(connection)
  {
    if(connection.getElement('a.main').hasClass('inner'))
    {
      return "inner"
    }
    return "outer"
  },
  
  getForm:function()
  {
    return this.options['page'].getElement('.new_connection');
  },
  
  update:function(updated,content)
  {
    updated.set('html', content);
    this.setConnections(updated);
    this.setConnectionForm();
  },
  
  perspectives:function()
  {
    return this.currentPage().getElement('.perspectives');
  },
  
  getFilters:function()
  {
    return $$('.filters dd a');
  },
  
  
  setSelected:function(el,context,activator)
  {
    var previous = activator.getParent(context).getChildren('.selected');
    if($defined(previous))
    {
      previous.removeClass('selected');
    }
    activator.getParent(el).addClass('selected');
  },
  
  requestAndReplace:function(url,replaced)
  {
    this.ajaxRequest(url,replaced, "replace");
  },
  
  requestAndUpdate:function(url, updated)
  {
    this.ajaxRequest(url,updated, "update");
  },
  
  ajaxRequest:function(url,target,type)
  {
    var obj = this;
    var type = type || "update";
    target.empty();
    target.adopt($('page_spinner').clone());    
    var args = {
      'url':url,
      'autoCancel':true,
      'evalScripts':true,
      'onSuccess':function(a,b,c,d)
      {
        if(type == "replace")
        {
          var new_page = a[0].replaces(target);
        } else
        {
          target.empty();
          var new_page = target.adopt(a[0])
        }
        
        obj.refresh(new_page);
        if(new_page.getElement('.map'))
        {
          obj.setMap();
        }
      }
    }  
    var call = new Request.HTML(args).get();
  },
  
  setConnectionForm:function(page)
  {
    var obj = this;
    var form = page.getElement('.new_connection')
    if($defined(form))
    {
      this.options['form'] = new NForm(form);
      this.options['form'].addEvent('success',function(a,b,c,d)
      {
        var updated = page.getElement('.content .connections');
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
    var obj = this;
    $('breadcrumbs').getElements('dd').each(function(el)
    {
      el.destroy();
    });
    var crumbs = this.el.getElements('.page h2 a');
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
        var page = obj.el.getElements(".page")[i];
        obj.selectPage(page);
      });
    });
    
  },
  
  hideForm:function(page)
  {
    var form = page.getElement('.new_connection');
    if($defined(form))
    {
     form.removeClass('expanded');
    }
  },
  
  selectPage:function(page)
  {
    if(!$defined(this.currentPage()))
    {
      this.options['page'] = page;
      if($defined(this.nextPage()))
      {
         this.nextPage().getAllNext('.page').destroy();
         this.nextPage().setStyle('width', 800);
         
      }
      this.slide.toElement(this.currentPage());
      this.currentPage().addClass('current_page');
      this.refresh(page);
    } 
    else if(page != this.currentPage())
    {
      this.currentPage().removeClass('current_page');
      this.currentPage().setStyle('width',300);
      this.hideForm(this.currentPage());
      this.options['page'] = page;
      if($defined(this.nextPage()))
      {
         this.nextPage().getAllNext('.page').destroy();
         this.nextPage().setStyle('width', 800);
         
      }
      this.slide.toElement(this.currentPage());
      this.currentPage().addClass('current_page');
      this.refresh(page);
    }
    
    
  },
  
  refresh:function(page)
  {
    this.setHat(page);
    this.setPerspectives(page);
    this.setConnections(page);
    this.setConnectionForm(page);
    this.hideForm(page);
    this.currentPage().setStyle('width',300);

  },
  
  setMap:function()
  {
    //page = params['page'];
    if($defined(this.map) )
    {
      this.map = null;
    }
    params = this.options['map']
    var map_div = $('map_div');//page.getElement('.map');
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
  }
});
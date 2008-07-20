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
    this.selectPage(this.el.getElement('.page'));
    this.setFilters();
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
              obj.requestAndUpdate(updated, this.getElement('a').get('href'));
              
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
  
  setFilters:function()
  {
    var obj = this;
    this.getFilters().each(function(action)
    {
      action.addEvent('click',function(ev)
      {
        
        obj.setSelected('dd','dl',this);
        var updated = this.getParent('.nuniverse').getElement('.connections');
        updated.set('html', '<h6>Loading...</h6>');
        var call = new Request.HTML({
          'url':this.href,
          onSuccess:function(a,b,c,d)
          {
            // var container = $('nuniverse').getElement('.content .connections');
            var new_content = a[0].replaces(updated);
            $('kind').setProperty('value', action.getElement('img').getProperty('alt'));
            setConnections(new_content);
          }
        }).get();
        return false;
      });
    });
  },
  
  setConnections:function(root)
  {
    var obj = this;
    root.getElements('.connection').each(function(connection)
    {
      connection.addEvent('mouseenter', function(ev)
      {
        this.addClass('hover');
      });

      connection.addEvent('mouseleave', function(ev)
      {
        this.removeClass('hover');
      });

      connection.addEvent('click', function(ev)
      {
        // change selected
        obj.setSelected('dd','dl',this.getElement('a'));
       
        // obj.options['page'] = this.getParent('.page');
        var parent = this.getParent('.page');
        obj.selectPage(parent);
        obj.nextPage().getChildren().destroy();
       
        obj.nextPage().adopt($('page_spinner').clone());
        if(this.getElement('a.main').hasClass('inner')) 
        {
          var call = new Request.HTML({
            'url':this.getElement('h3 a').getProperty('href'),
            onSuccess:function(a,b,c,d)
            {
              var new_page = a[0].replaces(obj.nextPage());
              obj.refresh(new_page);
              if(new_page.getElement('.map'))
              {
                obj.setMap();
              }
            },
            'evalScripts':true
          }).get();
         
        } 
        else
        {
          window.open(this.getElement('a.main').getProperty('href'), '_blank');
        }
      });
      
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
    });
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
  
  requestAndUpdate:function(updated, url)
  {
    var obj = this;
    // removes previous subcontent
    updated.empty();
    updated.set('html', '<h6>Loading...</h6>');
    var call = new Request.HTML({
         'url':url,
         'autoCancel':true,
         'update':updated,
         onSuccess:function(a,b,c,d)
         {
           obj.setConnections(updated);
           //obj.setMap(updated);
           if(updated.getElement('.map'))
           {
             obj.setMap();
           }
         },
         'evalScripts':true
    }).get();
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
    if(page != this.currentPage())
    {
      if($defined(this.currentPage()))
      {
        this.currentPage().removeClass('current_page');
        this.currentPage().setStyle('width',300);
        this.hideForm(this.currentPage());
      }
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
       this.map.addControl(new GMapTypeControl());
       this.map.addControl(new google.maps.LocalSearch(), new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(10,20)));
       params['markers'].each(function(m)
       {
         var marker = new GMarker(new GLatLng(m['latitude'],m['longitude']), {title:m['title'], draggable:true});
         
         this.map.addOverlay(addInfoWindowToMarker(marker),"<h2 style='color:#333'>YEAH</h2>", {});
         
       },this);
       }
       
    } 
  }
});
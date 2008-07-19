var Nuniverse = new Class({
  Implements: Options,
  options:{
    form:null,
    nav:null
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
    return this.currentPage().getNext('.page');
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
          }
        },
        'mouseleave':function(ev){
          this.removeClass('expanded');
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
        
        if(this.getElement('a.main').hasClass('inner')) 
        {
          // obj.options['page'].setStyle('width', '400');
          //next.set('html', '<h6>Loading...</h6>');
          var call = new Request.HTML({
            'url':this.getElement('h3 a').getProperty('href'),
            onSuccess:function(a,b,c,d)
            {
              obj.selectPage(parent);
              if($defined(obj.nextPage()))
              {
                var new_page = a[0].replaces(obj.nextPage());
              }
              else
              {
                var new_page = a[0].inject(obj.currentPage(),'after');
              }
              
              obj.refresh(new_page);
            },
            'evalResponse':true,
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
         onSuccess:function(a,b,c,d)
         {
           updated.set('html', c);
           obj.setConnections(updated);
         },
         'evalResponse':true,
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
  
  selectPage:function(page)
  {
    if(page != this.currentPage())
    {
      if($defined(this.currentPage()))
      {
        this.currentPage().removeClass('.current_page');
        this.currentPage().setStyle('width',300);
        this.currentPage().getElement('.perspectives').removeClass('.current');
      }
      this.options['page'] = page;

      if($defined(this.nextPage()))
      {
         this.nextPage().getAllNext('.page').destroy();
         this.nextPage().setStyle('width', 800);
      }

      this.slide.toElement(this.currentPage());
      this.currentPage().addClass('.current_page');
      this.currentPage().getElement('.perspectives').addClass('.current'); 
      this.refresh(page);     
    }
    
  },
  
  refresh:function(page)
  {
    this.setHat(page);
    this.setPerspectives(page);
    this.setConnections(page);
    this.setConnectionForm(page);
    this.currentPage().setStyle('width',300);
  }
});
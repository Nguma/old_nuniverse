var Nuniverse = new Class({
  initialize:function()
  {
    this.el = $('nuniverse');
    this.slide = new Fx.Scroll(this.getScroller());
    this.setFilters();
    this.setPerspectives();
    this.setConnections(this.el);
    this.setConnectionForm();
    this.setHat();
  },
  
  getScroller:function()
  {
    return this.el.getElement('.scroller');
  },
  
  getPreview:function()
  {
    return this.getNav().getNext('.content');
  },
  
  getNav:function()
  {
    return this.el.getElement('div.selected');
  },
  
  setPerspectives:function()
  {
    var obj = this;
    this.getPerspectives().each(function(action)
     {
       action.addEvent('click',function(ev)
       {
         obj.setSelected('dd','dl',this);
         var updated = obj.getPreview();

          if(this.hasClass('map'))
          {
            updated.empty();
            updated.adopt($('map_div'));
          }
          else
          {
            updated.set('html', '<h6>Loading...</h6>');
            obj.requestAndUpdate(updated, this.get('href'));
          }
         
         return false;
         });
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
        obj.getForm().setProperty('value', this.getElement('.path').get('text'));
        
        if(this.getElement('h3 a').hasClass('inner')) 
        {
          var parent_content = this.getParent('.content');
          parent_content.setStyle('width', '340px');
          obj.setSelected('.content','.body',this.getParent());
          var next = obj.slideToPath(parent_content);
          next.set('html', '<h6>Loading...</h6>');
          var call = new Request.HTML({
            'url':this.getElement('h3 a').getProperty('href'),
            onSuccess:function(a,b,c,d)
            {
              obj.update(next,c);
            }
          }).get();
          obj.refresh();
        } 
        else
        {
          window.open(this.getElement('h3 a').getProperty('href'), '_blank');
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
    return this.el.getElement('.new_connection').getElement('.path');
  },
  
  update:function(updated,content)
  {
    updated.set('html', content);
    this.setConnections(updated);
  },
  
  getPerspectives:function()
  {
    return $$('.perspectives dd a');
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
         evalResponse:true,
         evalScripts:true
    }).get();
  },
  
  setConnectionForm:function()
  {
    var obj = this;
    
    $$('form .dynamo').each(function(button)
    {
        var form = button.getParent('form');
        button.addEvent('click', function(ev)
        {
          // this.getParent('form').getChild('.restricted').setProperty('value', 1);
          var submission = new Request.HTML({
            'url':form.get('action'),
            onSuccess:function(a,b,c,d)
            {
              var updated = obj.getPreview().getElement('dl');
              updated.grab(a[0],'top');
              
              obj.setConnections(updated)
            }
          }).post(form);

          return false;
        });
    });
  },
  
  getTitle:function()
  {
    return this.el.getElement('h1');
  },
  
  setHat:function()
  {
    var obj = this;
    var title = this.getTitle();
    title.empty();
    var crumbs = this.el.getElements('.content dt a');
    crumbs.each(function(crumb,i)
    {
      var c = crumb.clone();
      title.adopt(c);
      c.addEvent('click', function(ev)
      {
        obj.slide.toElement(obj.el.getElements(".content")[i]);
      });
    });
    
  },
  
  slideToPath:function(content)
  {
    content.getAllNext('.content').destroy();
    var next = $('content_template').getElement('.content').clone();
    next.setStyle('width','700px');
    this.el.getElement('.body').adopt(next);
    this.slide.toElement(content);
    return next;
  },
  
  refresh:function()
  {
    this.setHat();
  }
});
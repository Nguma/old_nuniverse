var Finder = new Class({
  Implements:[Events,Options],
  options:{
  },
  
  initialize:function(el)
  {
    this.el = el;
    this.setEvents();
  },
  
  input:function()
  {
    return this.el.getElement('input#query');
  },
  
  suggestionsArea:function()
  {
    return this.el.getElement('.suggestions');
  },
  
  setEvents:function()
  {
    this.input().addEvents(
      {
        'focus':this.focusing.bind(this),
        'blur':this.blur.bind(this),
        'keyup':this.capture.bindWithEvent(this)
      },this);
  },
  
  capture:function(ev)
  {
    switch(ev.key)
    {
      case "enter":
        this.submit();
        break;
      default:
        this.find();
    }
  },
  
  find:function()
  {
    var call =  new Request.HTML({
      'url':'/ws/find?service=nuniverse&query='+this.input().getProperty('value'),
      'update':this.suggestionsArea(),
      'autoCancel':true
    },this).get();
  },
  
  submit:function()
  {
    var obj = this;
    var call =  new Request.HTML({
      'url':'/connect',
      'data':{
        'query':this.input().getProperty('value'),
        'authenticity_token':this.el.getElement('form input').getProperty('value')
        },
      onSuccess:function(a,b,c,d)
      {
        obj.fireEvent('connect',[a,b,c,d])
      }
    },this).post();    
  },
  
  blur:function()
  {
    this.collapse();
  },
  
  focusing:function()
  {
   
    this.expand();
  },
  
  collapse:function()
  {
    if(!this.isExpanded()) return;
    this.el.removeClass('expanded');
    this.input().setProperty('value','');
    this.suggestionsArea().empty();
  },
  
  expand:function(startValue)
  {
    this.input().focus();
    if(this.isExpanded()) return;
    this.el.addClass('expanded');
    var startValue = startValue || ""
    this.input().focus();
    this.input().setProperty('value',startValue);
    
  },
  
  isExpanded:function()
  {
    if(this.el.hasClass('expanded')) return true;
    return false;
  },
  
  toggle:function()
  {
    if(this.isExpanded())
    {
      this.collapse();
    }
    else
    {
      this.expand();
    }
  }
  
  
});
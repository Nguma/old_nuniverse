var Section = new Class({
  implements:[Events,Options],
  options:{
    form:null
  },
  
  initialize:function(el,options)
  {
    this.el = el;
    this.setOptions(options);
    
    
  },
  
  setConnections:function()
  {
    this.el.getElements('.connections dd').each(function(connection)
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
  
  clear:function()
  {
    form = null;
  }
  
  
});
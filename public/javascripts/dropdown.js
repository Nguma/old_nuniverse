var Dropdown = new Class({
  Implements:[Events,Options],
  options:{
    change:$empty
  },
  
  initialize:function(el, options)
  {
    this.el = el;
    this.setOptions(options);
    this.setEvents();
  },
  
  expand:function(ev)
  {
    if(this.el.hasClass('expanded')) return;
    ev.preventDefault();
    ev.stopPropagation();
    this.el.addClass('expanded');
  },
  
  collapse:function()
  {
    if(!this.el.hasClass('expanded')) return;
    this.el.removeClass('expanded');
  },
  
  setEvents:function()
  {
    this.el.removeEvents();
    this.el.addEvents({
      'mouseleave':this.collapse.bind(this),
      'click':this.expand.bindWithEvent(this)
    },this);
    this.setItems();
    this.setTabs();
  },
  
  items:function(css_class)
  {
    
    return this.el.getChildren('.item');
  },
  
  tabs:function(item)
  {
    var item = item || this.el;
    return item.getElements('.tabs a')
  },
  
  setItems:function()
  {    
    this.items().each(function(item)
    {
      item.removeEvents();
      item.getElement('a.service').addEvent('click',function(ev) {ev.preventDefault();});
      item.addEvents({
        'click':this.selectItem.bindWithEvent(this, item),
        'mouseenter':this.onItemHover.bind(this,item),
        'mouseleave':this.onItemLeave.bind(this,item),  
      },this);
     
    },this);
  },
  
  setTabs:function()
  {
    this.tabs().each(function(tab)
    {
      tab.removeEvents();
      tab.addEvents({
        'click':this.selectTab.bindWithEvent(this,tab),
        'mouseenter':this.onTabHover.bind(this,tab),
        'mouseleave':this.onTabLeave.bind(this,tab),  
      },this); 
    },this);   
    this.tabs()[0].addClass('selected');
  },
  
  selectItem:function(ev,item)
  {
    ev.stopPropagation();
    ev.preventDefault();
    this.fireEvent('onChange', this.selectedTab(item).getProperty('href'));
    this.collapse();
    if(item == this.selectedItem()) return;
    this.selectedItem().removeClass('selected');
    item.addClass('selected');
    this.el.getElement('dt .label').set('text', item.getElement('.service').get('text').toLowerCase());
    
    
  },
  
  selectTab:function(ev,tab)
  {
    if(tab == this.selectedTab(tab.getParent('dd.item'))) return;
    this.selectedTab(tab.getParent('dd.item')).removeClass('selected');
    tab.addClass('selected');
    ev.preventDefault();
  },
  
  onTabHover:function(tab)
  {
    tab.addClass('hover');
  },
  
  onTabLeave:function(tab)
  {
    tab.removeClass('hover');
  },
  
  onItemHover:function(item)
  {
    if(item.hasClass('selected')) return;
    item.addClass('hover');
  },
  
  onItemLeave:function(item)
  {
    item.removeClass('hover');
  },
  
  selectedTab:function(scope)
  {
    var scope = scope || this.el;
    return scope.getElement('.tabs .selected');
  },
  
  selectedItem:function()
  {
    return this.el.getChildren('.selected')[0];
  }
  
});
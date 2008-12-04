var PopUp = new Class({
  Extends:Steppable,
  options: {
    draggable:false,
    offset:{'x':0,'y':0},
    update:'.content'
  },
  
  initialize:function(el, options) {
    this.el = $(el);
   
    this.parent(el, options);
    this.content = this.options.update;

    
    this.setOptions(options);
    this.setBehavior();
  },
  
  collapse:function(ev) {
    if($defined(ev)) { ev.preventDefault();}
    this.fireEvent('onCollapse', this)
    this.el.addClass('hidden');
  },
  
  expand:function(ev) {
    if($defined(ev)) { ev.preventDefault();}
    if(!this.el.hasClass('hidden')) { return; }
    this.el.setStyles({
      'top':this.options.offset.y,
      'left':this.options.offset.x
    });
    this.el.removeClass('hidden');
    this.fireEvent('onExpand');
  },
  
  enableDrag:function() {
    this.options.drag.attach();
  },
  
  disableDrag:function() {
    this.options.drag.detach();
  },
  
  setBehavior:function() {

    if(this.options.draggable == true) {
      
      this.options.drag = new Drag.Move(this.el);
      this.el.getElement('.content').addEvents({
               'mouseenter':this.disableDrag.bind(this),
               'mouseleave':this.enableDrag.bind(this)
           });

    }
    var close_btns = this.el.getElements('.cancel_btn').concat(this.el.getElements('.close_btn'));
    
    close_btns.each(function(lnk) {
      lnk.addEvent('click', this.collapse.bindWithEvent(this));
    },this);
    
  },
    
  execute:function(ev, lnk) {
    ev.preventDefault();
    this.request.url = lnk.getProperty('href');
    this.request.get();
  },
  

  
  updateWith:function(el) {
    // 
    // 
    // 
    this.content.empty();

    this.content.set('html',el.getElement('.content').get('html'));
   
    this.request.options.update = this.content;
    this.setTriggers(this.content);
    this.fireEvent('onUpdate');
  }
})
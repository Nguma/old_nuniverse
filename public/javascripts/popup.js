var PopUp = new Class({
  Implements:[Events, Options],
  options: {
    draggable:false,
    offset:{'x':0,'y':0},
    content:$('content')
  },
  
  initialize:function(el, options) {
    this.el = $(el);
    this.setOptions(options);
    this.setBehavior();
    this.setEvents();
    this.setRequest();
  },
  
  collapse:function(ev) {
    if($defined(ev)) { ev.preventDefault();}
    this.fireEvent('onCollapse', this)
    this.el.addClass('hidden');
  },
  
  expand:function(ev) {
    if($defined(ev)) { ev.preventDefault();}
    this.el.setStyles({
      'top':this.options.offset.y,
      'left':this.options.offset.x
    })
    this.el.removeClass('hidden');
    
  },
  
  enableDrag:function() {
    // this.options.drag.attach();
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
      })
    }
    var close_btns = this.el.getElements('.cancel_btn').concat(this.el.getElements('.close_btn'));
    
    close_btns.each(function(lnk) {
      lnk.addEvent('click', this.collapse.bindWithEvent(this));
    },this);
    
  },
  
  setEvents:function() {
    // this.el.getElements('.dynamic_lnk').each(function(lnk) {
    //     lnk.addEvent('click', this.execute.bindWithEvent(this, lnk));
    //   },this);

    if(this.el.getProperty('id') == undefined ) { return; }
    
  },
  
  setRequest:function() {
    // this.request = new Request.HTML(
    //      {
    //        url:"",
    //        update:this.options.content,
    //        onSuccess:this.onUpdate.bind(this)
    //      })
  },
  
  execute:function(ev, lnk) {
    ev.preventDefault();
    this.request.url = lnk.getProperty('href');
    this.request.get();
  },
  
  onUpdate:function() {
   
  }
})
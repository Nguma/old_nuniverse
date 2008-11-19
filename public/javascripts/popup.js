var PopUp = new Class({
  Implements:[Events, Options],
  options: {
    draggable:false,
    content:$('content')
  },
  
  initialize:function(el, options) {
    this.el = $(el);
    this.setOptions(options);
    this.setBehavior();
    // this.setEvents();
    this.setRequest();
  },
  
  collapse:function(ev) {
    if($defined(ev)) { ev.preventDefault();}
    
    this.el.addClass('hidden');
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
    


    this.el.getElements('.close_btn','.cancel_btn').each(function(lnk){
      lnk.addEvent('click', this.collapse.bindWithEvent(this));
    },this);
    

  },
  
  setEvents:function() {
    this.el.getElements('.dynamic_lnk').each(function(lnk) {
      lnk.addEvent('click', this.execute.bindWithEvent(this, lnk));
    },this);
  },
  
  setRequest:function() {
    this.request = new Request.HTML(
      {
        url:"",
        update:this.options.content,
        onSuccess:this.onUpdate.bind(this)
      })
  },
  
  execute:function(ev, lnk) {
    ev.preventDefault();
    this.request.url = lnk.getProperty('href');
    this.request.get();
  },
  
  onUpdate:function() {
   
  }
})
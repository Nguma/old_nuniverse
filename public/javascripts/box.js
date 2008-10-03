var Box = new Class({
  options:{},
  
  initialize:function(el) {
    this.el = $(el);
    this.setBehaviors();
  },
  
  content:function() {
    return this.el.getElement('.content');
  },
  
  expand:function() {
    
    this.options['scroll'] = new Fx.Scroll(this.el,{
      transition: Fx.Transitions.Cubic.easeOut
    });
    this.content().removeClass('hidden');
    this.el.addClass('expanded');
    // windowScroll.toElement(this.el);
    
    
  },
  
  collapse:function() {
    this.el.removeClass('expanded');
    delete this.options['scroll'];
  },
  
  toggle:function() {
    if(this.isExpanded()) {
      this.collapse();
    }
    else {
      this.expand();
    }
  },
  
  setBehaviors:function() {
    this.el.addEvents({
      'mouseenter':this.focus.bind(this),
      'mouseleave':this.unfocus.bind(this)
    },this);
    
    if(this.el.hasClass('card')) {
      this.el.addEvents({
       'mousedown':this.startDrag.bind(this),
       'mouseup':this.stopDrag.bind(this)
      },this);
    }
    
    if(!this.isExpandable()) return;
    this.expandButton().addEvent('click', this.toggle.bind(this));
  },
  
  isExpandable:function() {
    if ($defined(this.expandButton())) return true
    return false
  },
  
  isExpanded:function() {
    if(this.el.hasClass('expanded')) return true;
    return false;
  },
  
  expandButton:function() {
    return this.el.getElement('.expander');
  },
  
  contentArea:function() {
    return this.el.getElement('.content');
  },
  
  focus:function() {
    this.el.addClass('hover');
  },
  
  unfocus:function() {
    this.el.removeClass('hover');
    if($defined(this.options['scroll'])) {
      this.options['scroll'].toTop();
    }
    
  },
  
  startDrag:function() {
    this.options['clone'] = this.el.clone();
    this.options['clone'].setStyles({
      'width':this.el.getCoordinates().width,
      'opacity':0.8,
      'position':'absolute',
      'z-index':34567890
    });
    this.options['clone'].makeDraggable();
    this.options['clone'].injectBefore(this.el);
    
    
  },
  
  stopDrag:function() {
    
  }
});
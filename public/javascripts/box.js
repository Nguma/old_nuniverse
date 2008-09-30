var Box = new Class({
  initialize:function(el) {
    this.el = $(el);
    this.setBehaviors();
  },
  
  expand:function() {
    this.el.addClass('expanded');
  },
  
  collapse:function() {
    this.el.removeClass('expanded');
  },
  
  toggle:function() {
    this.el.toggleClass('expanded');
    if($defined(this.contentArea())) {
      this.contentArea().toggleClass('hidden');
    }
  },
  
  setBehaviors:function() {
    this.el.addEvents({
      'mouseenter':function(ev){this.addClass('hover');},
      'mouseleave':function(ev){this.removeClass('hover');}
    });
    
    if(!this.isExpandable()) return;
    this.expandButton().addEvent('click', this.toggle.bind(this));
  },
  
  isExpandable:function() {
    if ($defined(this.expandButton())) return true
    return false
  },
  
  expandButton:function() {
    return this.el.getElement('.expander');
  },
  
  contentArea:function() {
    return this.el.getElement('.content');
  }
});
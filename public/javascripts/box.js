var Box = new Class({
  Implements:[Options],
  
  options:{
    
  },
  
  initialize:function(el) {
    this.el = $(el);
    this.setBehaviors();
  },
  
  actions:function() {
    return this.el.getElement('.actions');
  },
  
  collapse:function() {
    this.el.removeClass('expanded');
    delete this.options['scroll'];
    
  },
  
  collapseOptions:function() {
    if($defined(this.options['scroll'])) {
      this.options['scroll'].toTop();
    }
  },
  
  commands:function() {
    return this.el.getElements('.command');
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
  
  expandButton:function() {
    return this.el.getElement('.expander');
  },
  
  expandInput:function(command) {
    this.expand();
    // $('input_box').injectInside(this.el, 'bottom');
    // this.scrollTo($('input_box'));
    // this.setOptionsBehaviors();
   
    
    // $('input_box').setStyles({
    //       'height':this.el.getCoordinates()['height'],
    //       'top':this.el.getCoordinates($('categories'))['top'] - 125
    //     });
    // this.inputBox = new Input($('input_box'),{
    //       onSuccess:function() {
    //         console.log("BLAH");
    //       }
    //     });
    inputBox.expand(command.getProperty('href'), command.getProperty('title'));
  },
  
  expandOptions:function(ev) {
    ev.preventDefault();
    this.expand();
    this.scrollTo(this.options());
  },
  
  focus:function() {
    this.el.addClass('hover');
  },
  
  isExpandable:function() {
    if ($defined(this.expandButton())) return true
    return false
  },
  
  isExpanded:function() {
    if(this.el.hasClass('expanded')) return true;
    return false;
  },
  
  unfocus:function() {
    this.el.removeClass('hover');
    if($defined(this.options['scroll'])) {
      this.scrollTo('top')
    }
  },
  
  onExpandInputClick:function(ev,command) {
    ev.preventDefault();
    this.expandInput(command);
  },
  
  options:function() {
    return this.el.getElement('.options');
  },
  
  scrollTo:function(el) {
    if($defined(this.options['scroll'])) {
      switch(el) {
        case 'top':
          this.options['scroll'].toTop();
          break;
        default:
          this.options['scroll'].toElement(el);
      }
      return true
    }
    return false
  },
  
  setBehaviors:function() {
    this.el.addEvents({
      'mouseenter':this.focus.bind(this),
      'mouseleave':this.unfocus.bind(this)
    },this);
    
    // if(this.el.hasClass('card')) {
    //       this.el.addEvents({
    //        'mousedown':this.startDrag.bind(this),
    //        'mouseup':this.stopDrag.bind(this)
    //       },this);
    //     }
    
    this.setCommands();
    this.setOptionsBehaviors();
     
    if(!this.isExpandable()) return;
    this.expandButton().addEvent('click', this.toggle.bind(this));
  },
  
  setCommands:function() {
    this.commands().each(function(command){
      command.addEvent('click',this.onExpandInputClick.bindWithEvent(this,command))
    },this);
  },
  
  setOptionsBehaviors:function() {
    var expand_options_bt = this.el.getElement('.expand_options');
    var collapse_options_bts = this.el.getElements('.collapse_options');
    if($defined(expand_options_bt)) {
      expand_options_bt.addEvent('click', this.expandOptions.bindWithEvent(this));
    }
    collapse_options_bts.each(function(bt) {
      bt.removeEvents();
      bt.addEvent('click', this.collapseOptions.bindWithEvent(this));
    },this);
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
    
  },
  
  toggle:function() {
    if(this.isExpanded()) {
      this.collapse();
    }
    else {
      this.expand();
    }
  }
});
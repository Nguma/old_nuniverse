var Box = new Class({
  Implements:[Options, Events, Triggerable, Requestable],
  
  options:{
    
  },
  
  initialize:function(el, options) {
    this.el = $(el);
    this.setOptions(options);
    this.setBehaviors();
    this.setTriggers(el);
    this.setRequest();
  },

  focus:function() {
    this.el.addClass('hover');
  },
  
  unfocus:function() {
    this.el.removeClass('hover');
    if($defined(this.options['scroll'])) {
      this.scrollTo('top')
    }
  },
  
  setBehaviors:function() {
    this.el.addEvents({
      'mouseenter':this.focus.bind(this),
      'mouseleave':this.unfocus.bind(this),
      'click':this.toggle.bindWithEvent(this)
    },this);

    this.el.getElements('a').each(function(lnk) {
      lnk.addEvent('click', function(ev) {ev.stopPropagation();})
    });
  },

  toggle:function() {
    this.fireEvent('onClick',this);
  }
});

  var Steppable = new Class({
    Implements:[Options,Events],
    options: {
      step:'.step',
      trigger:'.trigger',
      scrollable:'.scrollable'
    },
    
    initialize:function(el, options) {
      this.el = $(el);
      this.setOptions(options);
      this.options.steps = this.el.getElements(this.options.step);
      this.options.current = this.options.steps[0];
      this.scroll = new Fx.Scroll(this.el.getElement(this.options.scrollable));
      this.setTriggers(this.el);
 
      
      this.el.getElements('.close_btn').each(function(btn) {
        btn.addEvent('click', this.collapse.bindWithEvent(this, btn));
      },this);
    },
    
    setTriggers:function(area) {
      area.getElements(this.options.trigger).each(function(trigger) {
         trigger.addEvent('click', this.onTrigger.bindWithEvent(this, trigger));
       },this)
    },
    
    collapse:function(ev) {
      if($defined(ev)) { ev.preventDefault();}
      this.select(this.options.steps[0])
      this.el.addClass('hidden');
    },
    
    onTrigger:function(ev, trigger) {
      ev.preventDefault();
      ev.stopPropagation();
      this.fireEvent('onTrigger', trigger);
      
      if(trigger.hasClass('next')) {
                    this.next();
                  } else if (trigger.hasClass('previous')) {
                    this.previous();
                  } else if (trigger.hasClass('same')) {
                   
                  } 
                  
               // this[trigger.getProperty('href')]();
      
    },
    
    previous:function() {
      var p = this.options.current.getPrevious(this.options.step);
      this.select(p);
    },
    
    next:function() {
      var n = this.options.current.getNext(this.options.step);
      this.select(n);
    },
    
    select:function(step) {
      if(step != undefined) {
        this.options.current.addClass('hidden');
        this.options.current = step;
        this.options.current.removeClass('hidden');
        // this.scroll.toElement(step);
        
      }
      
    }
    
  });
  

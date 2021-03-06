var Expandable = new Class({
  expand:function() {
    this.el.removeClass('hidden');
    this.fireEvent('onExpand');
  },
  
  collapse:function() {
    // this.el.addClass('hidden');
    this.fireEvent('onCollapse');
  },
  
  toggle:function() {
    if(this.el.hasClass('hidden')) {
      this.expand();
    } else {
      this.collapse();
    }
  }
});

var Triggerable = new Class({
  setTriggers:function(area) {    
    area.getElements('.trigger').each(function(trigger) {
      trigger.removeEvents();
      trigger.addEvent('click', this.onTrigger.bindWithEvent(this, trigger));
     },this)
  },
  
  onTrigger:function(ev, trigger) {
    
    ev.preventDefault();
    ev.stopPropagation();
    this.fireEvent('onTrigger', trigger);
  }
});

var Requestable = new Class({
  
  setRequest:function() {
    this.request = new Request.HTML({
               url:this.options.requestUrl,
               link:'cancel',
               onComplete:this.onComplete.bind(this),
               onRequest:this.onRequest.bind(this),
               onSuccess:this.getRequestResult.bind(this)
             }, this)
    if($chk(this.options.update)) {this.request.options.update = this.options.update}
      
    // Timeout definition
    this.timeout = $empty
  },
  
  callRequest:function(params) {
    $clear(this.timeout);

    if(!$chk(params)) {params = {}}
    if ($chk(params.url)) {this.request.options.url = params.url;}
    if(!$chk(params.delay)) { params.delay = 250; } 

    this.timeout = this.sendRequest.delay(params.delay,this);
  },
  
  onRequest:function() {
    if($chk(this.request.options.update)) {this.request.options.update.empty();}
    this.startSpinning();
    this.fireEvent('onRequest');
  },
  
  onComplete:function() {
    this.stopSpinning();
    this.fireEvent('onComplete');
  },
  
  sendRequest:function() {
    // if($defined(this.el.getElement('.data'))){this.el.getElement('.data').empty();}
  
    if($chk(this.el.getElement('form'))) {
      this.request.post(this.el.getElement('form'));
    } else {
      this.request.post(this.el);
    }
    
  },
  
  getRequestResult:function() {
    this.fireEvent('onSuccess',this.request.options.update);
  },
  
  startSpinning:function() {
    if(!$defined(this.options.spinner)) return;
   
    this.options.spinner.removeClass('hidden');
  },
  
  stopSpinning:function() {
    if(this.options.spinner == undefined) return;

    this.options.spinner.addClass('hidden');
  }
});

  var Keymapped = new Class({
   
    
    setKeyListener:function(listeners) {
      if(!$chk(listeners)) return;
      this.listeners = listeners;
      
      this.listeners.each(function(listener) {
        listener.removeEvents();
        listener.addEvents({
        'keyup':this.onKeyUp.bindWithEvent(this, listener),
        'keydown':this.onKeyDown.bindWithEvent(this, listener)
        // 'keypress':function(ev) {ev.preventDefault();}
        
        },this);
      },this);
    },
    
    onKeyUp:function(ev, listener) {
      ev.preventDefault();
      ev.stopPropagation();     
      this.fireEvent('onKeyUp',[ev.key, listener]);
      if(listener.getProperty('value') == '') {
        listener.removeClass('filled');
        this.fireEvent('onClear',listener);
      } else {
        listener.addClass('filled');
      }
      

    },
    
    onKeyDown:function(ev) {
      if(ev.key == "enter") {
        ev.preventDefault();
        this.fireEvent('onEnter')
      }
    }
    
  });
  
  
  var Taggable = new Class({
    addTag:function(label) {
       var tag = this.el.getElement('a.tag').clone();
       tag.set('text', label);
       this.el.getElement('.tags').adopt(tag, 'bottom');
       tag.addClass('.selected');
       this.el.getElement('.input').set('value', '');
       this.setTriggers(this.el.getElement('div.tags'));
       this.el.getElement('input.tags').set('value', this.el.getElement('input.tags').get('value')+','+label);
    },
    
    removeTag:function(t) {
      label = ","+t.get('text');
      t.destroy();
      this.el.getElement('input.tags').set('value', this.el.getElement('input.tags').get('value').replace(label, ','));
    },
    
    
  });
  
  var Steppable = new Class({
    Implements:[Options,Events,Requestable, Keymapped, Expandable, Triggerable],
    options: {
      step:'.step',
      trigger:'.trigger',
      scrollable:'.scrollable',
      requestUrl:$empty,

      delay:200
    },
    
    initialize:function(el, options) {
      
      this.el = $(el);
      this.setOptions(options);
      if($chk(this.options.listener)) {
        this.setKeyListener(this.options.listener);
      }
     
      this.setRequest();
      if(this.el == null) return;
      this.options.steps = this.el.getElements(this.options.step);
      if ($chk(this.options.steps)) {
        this.options.current = this.options.steps[0];
      }
      
     // this.scroll = new Fx.Scroll(this.el.getElement(this.options.scrollable));
      this.setTriggers(this.el);
 
      
      this.el.getElements('.close_btn').each(function(btn) {
        btn.addEvent('click', this.collapse.bindWithEvent(this, btn));
      },this);
    },
    
    
    
    collapse:function(ev) {
      if($defined(ev)) { ev.preventDefault();}
      this.select(this.options.steps[0])
      this.el.addClass('hidden');
    },
  
    
    previous:function() {
      var p = this.options.current.getPrevious(this.options.step);
      this.select(p);
    },
    
    reset:function() {
      if($chk(this.el.getElement('.suggestions'))) {
        this.el.getElement('.suggestions').empty();
      }
      if($chk(this.listener)) {

        this.listener.set('value', '');
        this.fireEvent('onClear', this.listener);
      }
    },

    
    next:function() {
      var n = this.options.current.getNext(this.options.step);
      this.select(n);
    },
    
    select:function(step, option) {
      if(step != undefined) {
        
        this.options.current.removeClass('current');
        this.options.current = step;
        this.options.current.getAllNext('.step').each(function(step) {
          step.removeClass('activated');
        });
        this.options.current.getAllPrevious('.step').each(function(step) {
          step.addClass('activated');
        });
        this.options.current.addClass('current');
        this.options.current.getElements('.option').each(function(option) {
          option.addClass('hidden');
        });
        if($chk(option)){
          option.removeClass('hidden')
        }
        this.setTriggers(this.options.current);
        var input = this.options.current.getElement('.input');
        if($chk(input)) {
           this.setKeyListener(input);
        }
      }
      
    },
    
    updateSelectedOption:function(option) {
      var selected_option_tag = option.getParent('.step').getElement('.selected_option');
      if(!$chk(selected_option_tag)) return;
      selected_option_tag.set('text', option.get('text').toLowerCase());
    }
    
  });
  

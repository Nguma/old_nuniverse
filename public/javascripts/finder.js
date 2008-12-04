var Expandable = new Class({
  expand:function() {
    this.el.removeClass('hidden');
    this.fireEvent('onExpand');
  },
  
  collapse:function() {
    this.el.addClass('hidden');
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

var Requestable = new Class({
  
  setRequest:function() {
    this.request = new Request.HTML({
               url:this.options.requestUrl,
               link:'cancel',
               update:this.options.update,
               onComplete:this.onComplete.bind(this),
               onRequest:this.onRequest.bind(this),
               onSuccess:this.getRequestResult.bind(this)
             }, this)
      
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
    this.request.options.update.empty();
    this.startSpinning();
    this.fireEvent('onRequest');
  },
  
  onComplete:function() {
    this.stopSpinning();
    this.fireEvent('onComplete');
  },
  
  sendRequest:function() {
    if($defined(this.el.getElement('.data'))){this.el.getElement('.data').empty();}
    this.request.options.update.removeClass('hidden');
    this.request.post(this.el.getElement('form'));
  },
  
  getRequestResult:function() {
    this.fireEvent('onSuccess',this.request.options.update);
  },
  
  startSpinning:function() {
    if(!$chk(this.options.spinner)) return;
   
    this.options.spinner.removeClass('hidden');
  },
  
  stopSpinning:function() {
    if(!$chk(this.options.spinner)) return;
    this.options.spinner.addClass('hidden');
  }
});

  var Keymapped = new Class({
    listener:$empty,
    
    setKeyListener:function(listener) {
      if(!$chk(listener)) return;
      this.listener = listener;
      this.listener.removeEvents();
      this.listener.addEvent('keyup', this.onKeyUp.bindWithEvent(this))
    },
    
    onKeyUp:function(ev) {
      this.fireEvent('onKeyUp',ev.key);
    }
    
  });
  
  var Steppable = new Class({
    Implements:[Options,Events,Requestable, Keymapped, Expandable],
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
    
    setTriggers:function(area) {
      area.getElements(this.options.trigger).each(function(trigger) {
        trigger.removeEvents();
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

      if(trigger.hasClass('next')) {
        this.next();
      } else if (trigger.hasClass('previous')) {
        this.previous();
      } else if (trigger.getProperty('href').match(/^#.*/)) {
        var gum = trigger.getProperty('href').match(/^#(\w+)#?(\w+)?/)
        // checks if step belongs to the form and displays it. other wise clones it as the next part of the form
        this.select($(gum[1]),$(gum[2]));
        
      }
               
      this.fireEvent('onTrigger', trigger);   
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
  

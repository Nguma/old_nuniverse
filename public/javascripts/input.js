var Input = new Class({
    Extends:PopUp,

    options:{
      'focused':false,
      'suggestUrl':null,
      'update':null,
      'trigger':'.trigger',
      'spinner':$empty
      //'onUpdate':$empty
      //'onSuggestionClick':$empty
    },
    
    initialize:function(el,options) {
      this.inputs = $(el).getElements('input.input');
      this.parent(el,options);

      this.setRequest();
    },
    
    setBehavior:function() {
      this.parent();
      this.inputs.each(function(input){
        input.removeEvents();
        input.addEvents({
        'focus':this.focus.bindWithEvent(this, input),
        'blur':this.blur.bindWithEvent(this, input),
        'keyup':this.keyup.bindWithEvent(this, input)
        },this);
      },this);
      
      this.triggers = this.el.getElements(this.options.trigger);
      this.triggers.each(function(t) {
          t.addEvent('click', this.onTrigger.bindWithEvent(this,t))
        }, this);
     
    },
    
    setRequest:function() {
      // this.request = new Request.HTML({
      //         url:this.options.suggestUrl,
      //         link:'cancel',
      //         update:this.options.update,
      //         onComplete:this.stopSpinning.bind(this),
      //         onRequest:this.startSpinning.bind(this),
      //         onSuccess:this.getUpdate.bind(this)
      //       }, this)
        
      // Timeout definition
      this.timeout = $empty
    },
    
    startSpinning:function() {
      this.options.spinner.removeClass('hidden');
    },
    
    stopSpinning:function() {
      this.options.spinner.addClass('hidden');
    },
    
    expand:function() {
      this.parent();
      this.el.getElements('input#input')[0].focus();
    },
    
    getUpdate:function() {
      this.fireEvent('onUpdate', this.options.update)
    },
    
    focus:function(ev,input) {
      this.options.focused = input;
    },
    
    blur:function(ev, input) {
      this.options.focused = null;
    },
    
    onTrigger:function(ev, trigger) {
      ev.preventDefault();
      this.fireEvent('onSelect',trigger);
    },
    
    keyup:function(ev, input) {

      if(this.options.focused != input) { return; }

      if(input.getProperty('value') == '') {
        this.fireEvent('onClear',input)
      } else {
        this.fireEvent('onChange', input);
      }
      
    },
    
    suggest:function() {
      $clear(this.timeout);
      this.timeout = this.retrieveSuggestions.delay(200,this);
    },
    
    retrieveSuggestions:function() {
      if($defined(this.el.getElement('.data'))){this.el.getElement('.data').empty();}
      this.options.update.removeClass('hidden');
      this.request.post(this.el.getElement('form'));
    },
    
    setSuggestions:function() {
      var suggestions = this.options.update.getElements('.connection');
      suggestions.each(function(connection) {
        connection.removeEvents();
        connection.addEvent('click',this.clickSuggestion.bindWithEvent(this, connection))
      },this);
    },
    
    clickSuggestion:function(ev,suggestion) {
      ev.preventDefault();
      this.fireEvent('onSuggestionClick',suggestion);
    }
    
  });
 
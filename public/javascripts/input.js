var Input = new Class({
    Extends:PopUp,

    Options:{
      'focused':false,
      'suggestUrl':null,
      'update':null,
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
      
    },
    
    setRequest:function() {
      this.request = new Request.HTML({
          url:this.options.suggestUrl,
          link:'cancel',
          update:this.options.update,
          onComplete:function() {
            $('spinner').addClass('hidden');
          },
          onRequest:function() {
            $('spinner').removeClass('hidden');
          },
          onSuccess:this.getUpdate.bind(this)
        }, this)
        
      // Timeout definition
      this.timeout = $empty
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
    
    keyup:function(ev, input) {
      
      if(this.options.focused != input) { return; }

        
    
      // if(this.input.getProperty('value').length == 0) {return;}
     
      if(input.getProperty('value') == '') {
        this.fireEvent('onClear',input)
      } else {
        this.fireEvent('onChange', input);
      }
      $clear(this.timeout);
      this.timeout = this.suggest.delay(200,this);
    },
    
    suggest:function() {
      if($defined(this.el.getElement('.data'))){this.el.getElement('.data').empty();}
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
 
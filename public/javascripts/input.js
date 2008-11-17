var Input = new Class({
    Implements:[Options,Events],
    Options:{
      'focused':false,
      'suggestUrl':null,
      'update':null,
      //'onUpdate':$empty
      //'onSuggestionClick':$empty
    },
    
    initialize:function(el,options) {
      this.setOptions(options)
      this.el = $(el);
      this.input = this.el.getElement('input.input');
      this.setEvents();
      this.setRequest();
    },
    
    setEvents:function() {
      this.input.removeEvents();
      this.input.addEvents({
        'focus':this.focus.bindWithEvent(this),
        'blur':this.blur.bindWithEvent(this),
        'keyup':this.keyup.bindWithEvent(this)
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
    
    getUpdate:function() {
      this.fireEvent('onUpdate', this.options.update)
    },
    
    focus:function(ev) {
      this.options.focused = true;
    },
    
    blur:function(ev) {
      this.options.focused = false;
    },
    
    keyup:function(ev) {
      if(this.options.focused == false) { return; }
      // if(this.input.getProperty('value').length == 0) {return;}
      $clear(this.timeout)
      this.timeout = this.suggest.delay(200,this);
    },
    
    suggest:function() {
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
 
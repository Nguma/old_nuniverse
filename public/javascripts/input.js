var Input = new Class({
    Implements:[Requestable, Expandable, Triggerable, Keymapped, Options, Events],
    
    options:{
      'focused':false,
      'requestUrl':null,
      'update':null,
      'trigger':'.trigger',
      'spinner':null
      //'onUpdate':$empty
      //'onSuggestionClick':$empty
    },
    
    initialize:function(el,options) {
      this.el = el;
      this.setOptions(options)
      this.setKeyListener(this.options.listeners);
      // this.parent(el,options);

      this.setRequest();
      return this;
    },
    
    setBehavior:function() {
      this.parent();
      this.triggers = this.el.getElements(this.options.trigger);
      this.triggers.each(function(t) {
          t.addEvent('click', this.onTrigger.bindWithEvent(this,t))
        }, this);
     
    },
    
    reset:function() {
      this.el.getElement('.suggestions').empty();
      this.listener.set('value', '');
      this.fireEvent('onClear', this.listener);
    },

    
    onTrigger:function(ev, trigger) {
      ev.preventDefault();
      this.fireEvent('onSelect',trigger);
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
 
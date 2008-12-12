var Input = new Class({
    Implements:[Requestable, Expandable, Triggerable, Keymapped, Options, Events],
    
    options:{
      'focused':false,
      'requestUrl':null,
      'update':null,
      'trigger':'.trigger',
      'spinner':$empty
      //'onUpdate':$empty
      //'onSuggestionClick':$empty
    },
    
    initialize:function(el,options) {
      this.inputs = $(el).getElements('input.input');
      this.el = el;
      this.setOptions(options)
      this.setKeyListener(this.options.listener);
      // this.parent(el,options);

      this.setRequest();
      return this;
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
    
    expand:function() {
      this.parent();
      this.el.getElements('input.input')[0].focus();
    },
    
    focus:function(ev,input) {
      this.options.focused = input;
    },
    
    reset:function() {
      this.el.getElement('.suggestions').empty();
      this.listener.set('value', '');
      this.fireEvent('onClear', this.listener);
    },
    
    blur:function(ev, input) {
      this.options.focused = null;
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
 
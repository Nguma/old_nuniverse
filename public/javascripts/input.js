

var Input = new Class({
    Implements:[Requestable],
    Extends:PopUp,

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
    
  
    expand:function() {
      this.parent();
      this.el.getElements('input#input')[0].focus();
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
 
var NForm = new Class({
  Implements: [Events, Options],
  options:{
    suggest_uri:"/suggest"
  },
  
  initialize:function(el)
  {
    this.el = el;
    this.inputize();
    this.setToggle();
    this.setActions();
  },
  
  //  Labelize: 
  //  Gets all labels within the form, 
  //  Sets their display to none,
  //  Assign the respective input / textarea the label value as default if empty and
  //  adds the class "blank" to it.
  labelize:function(input)
  {
    var label = input.getPrevious('label');
    if($defined(label))
    {
      input.setProperty('value',label.get('text'));
      input.addClass('blank');
      label.setStyle('display', 'none');      
    }
  },
  
  inputize:function()
  {
    this.inputs().each(function(input)
    {
      input.removeEvents();
      if(input.getProperty('type') != "submit") 
      {
        input.addEvent('focus',this.onInputFocus.bind(this,input));
        input.addEvent('blur', this.onInputBlur.bind(this,input));
        
        // this.labelize(input);
      };
      
    },this);
  },
  
  inputs:function()
  {
    return [this.el.getElements('input'), this.el.getElements('textarea')].flatten();
  },
  
  onInputBlur:function(input)
  {
    input.removeEvent('keyup');
    this.fireEvent('blur', input);
    // if(input.getProperty('value') == "" || input.getProperty('value') == input.getPrevious('label').get('text'))
    //    {
    //      //this.labelize(input);
    //    }
  },
  
  onInputFocus:function(input)
  {
    input.addEvent('keyup', this.onInputChange.bind(this,input));
    this.fireEvent('focus', input);
    if(input.hasClass('blank'))
    {
      input.removeClass('blank');
      input.setProperty('value', "")
    }
  },
  
  onInputChange:function(input)
  {
    if(!$defined(this.suggestions())) return;
    this.findSuggestions()
  },
  
  setActions:function()
  {
    this.el.getElements('.dynamo').each(function(button)
    {
      button.addEvent('click',this.submit.bindWithEvent(this));
    },this);
  },
  
  submit:function(ev)
  {
    ev.preventDefault();
    ev.stopPropagation();
    var obj = this;
    if($defined(this.el.getElement('form')))
    {
      var url = this.el.getElement('form').get('action');
    }
    else
    {
      url = this.el.get('action');
    }
    
    var submission = new Request.HTML({
      'url':url,
      'update':this.suggestions(),
      'data':{'authenticity_token':this.getToken()},
      onSuccess:function(a,b,c,d)
      {
        obj.clearInputs(); 
        obj.fireEvent('success',[a,b,c,d]);
      }
    }).post(this.el);
    return false;
  },
  
  getToken:function()
  {
    this.el.getElements('input').each(function(input)
    {
      if($defined(input.getProperty('name') == 'authenticity_token'))
      {
        return input.getProperty('value');
      }
    });
  },
  
  findSuggestions:function()
  {
    var obj = this;
    var submission = new Request.HTML({
      'url':this.options['suggest_uri'],
      'update':this.suggestions(),
      onSuccess:function(a,b,c,d)
      {
        obj.fireEvent('suggest',obj.suggestions());
      }
    }).post(this.el.getElement('fieldset'));
    return false;
  },
  
  clearInputs:function()
  {
    this.inputs().each(function(input)
    {
      if(input.getProperty('type') == "text")
      {
        input.setProperty('value','');
      }
    });
    
  },
  
  setToggle:function()
  {
    this.el.getParent('.nuniverse').getElements('.toggle').each(function(toggle)
    {
      toggle.addEvent('click', this.toggle.bind(this));
    },this);
    
  },
  
  toggle:function(force)
  {
    if(this.el.hasClass('expanded'))
    {
      this.collapse();
    }
    else
    {
      this.expand();
    }
  },
  
  expand:function()
  {
    this.el.addClass('expanded');
    this.el.getElement('.toggle').set('text', '- Add');
  },
  
  collapse:function()
  {
    if(this.el.hasClass('expanded'))
    {
      this.el.removeClass('expanded');
      this.el.getElement('.toggle').set('text', '+ Add');
    } 
  },
  
  suggestions:function()
  {
    return this.el.getElement('.suggestions');
  }
});
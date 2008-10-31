var Input = new Class({
  Implements:[Events, Options],
  
  options: {
    
  },
  
  initialize:function(el, options) {
    this.el = $(el);
    this.setOptions(options)
    if(this.el != undefined) {
      this.setBehaviors();
    }
  },
  
  addAnotherPrompt:function() {
    this.setInput('');
    this.setLabel('Add another one?');
  },
  
  addSuggestionsBehaviors:function() {
    
    this.el.getElements('.suggestion').each(function(suggestion) {
      if(!suggestion.hasClass('bookmark')) {
        suggestion.makeDraggable({
          'droppables':$('content'),
          'clone':true,
          'onDrop':function(el, droppable) {
            var call = new Request.HTML({
              'url':el.getElement('.save').getProperty('href'),
              'onSuccess':function(a,b,c,d) {
                $('content').adopt(a);
                el.destroy();
              }
              
            }).get();
          }
        })
        suggestion.getElement('a').addEvent('click', this.onSuggestionClick.bindWithEvent(this, suggestion)); 
      }
    },this);
    var obj = this;
    if($defined(this.el.getElement('.pagination'))) {
      
      this.el.getElement('.pagination').getElements('a').each(function(page){
        page.addEvent('click', function(ev) {
          ev.preventDefault();
          obj.getSuggestions(page.getProperty('href'));
        },this);
      },this);
    }
  },
  
  box:function() {
    if($defined(this.options['box'] )) return this.options['box'];
    return this.el.getParent('.box');
  },
  
  collapse:function(ev) {
    if($defined(ev)) {
      ev.preventDefault();
    }
    this.hide();
  },
  
  expand:function(command, description) {
    this.setCommand(command, description);
    this.setInput("");
    this.setCommandDisplay(true);
    $('input').focus();    
    if(this.el.hasClass('hidden')) {
      this.show();  
      return true;
    }
    return false;
  },
  
  hide:function() {
    this.el.addClass('hidden');
  },
  
  isInUse:function() {
   if(this.getCommandValue() == null) return false
   if(this.getInputValue().length < 1) return false 
   return true
  },
  
  getBodyValue:function() {
    return $('extra_input').getProperty('value');
  },
  
  
  getCommandField:function() {
    return $('command');
  },
  
  getCommandValue:function() {
    var match = $('command').getProperty('value').toLowerCase().match(/^(new)?\s?(\b\w+\b)/);
    if(match != null) {
      return match[2];
    } else {
      return null;
    }
    
  },
  
  getFileField:function() {
    return $('image_url_uploaded_data');
  },
  
  getFileFieldArea:function() {
    return $('file_field');
  },
  
  getInputValue:function() {
    return $('input').getProperty('value');
  },
  
  getSuggestions:function(url) {
    if($defined(this.options['delay'])) {$clear(this.options['delay']);}
    this.options['delay'] = this.suggest.delay(500, this, url);
    this.spinner().setStyle('display','block');
     $('suggestions').empty();
  },
  
  onCommandChange:function() {  
     $('suggestions').empty();
  },
  
  onKey:function(ev) {
    if(this.el.hasClass('disabled')) return;
     switch(ev.key){
        case "esc":
          this.hide();
          break;
        case "enter":
          if(!this.isInUse()) return; 
          if(this.getCommandValue() == "invite" || this.getCommandValue() == "email") {
            if($('extra_input').hasClass('hidden')) {
              $('extra_input_label').set('text','Add a personal note or Press enter to send');
              $('extra_input').removeClass('hidden');
              $('extra_input').focus();
            } else {
              this.submit(this.submitUrl());
            }
          } else {
            this.submit(this.submitUrl());
          }
         break;
        case "space":
          if(!this.isInUse()) {
            if(this.el.hasClass('hidden')) {this.show();}
          }
        default:    
          this.setCommandDisplay();
      }
  },
  
  onSuggestComplete:function() {
    this.spinner().setStyle('display','none')
  },
  
  onSuggestionClick:function(ev,suggestion) {
    if(this.getCommandValue() != "search") {
      ev.preventDefault(); 
      this.setInput(suggestion.getElement('a').get('text'));
      this.submit(suggestion.getElement('a').getProperty('href'));
    }

  },
  
  onSubmitSuccess:function() {
    this.hide();
    this.fireEvent('success');
  },
  
  setBehaviors:function() {
    this.getFileField().addEvents({
      'change':this.submit.bind(this,this.submitUrl())
    },this);
    this.getCommandField().addEvent('change', this.onCommandChange.bind(this));
    if($defined(this.el.getElement('a.collapse'))){
      this.el.getElement('a.collapse').addEvent('click', this.hide.bindWithEvent(this));
    }
    this.el.addEvent('keyup', this.onKey.bindWithEvent(this));

  },
  
  setCommand:function(command, description) {
    this.getCommandField().setProperty('value', command);
    if($defined(description)) {this.setLabel(description);}
  },
  
  setCommandDisplay:function(reset) {
    
    if(reset == true) {
      this.el.getElement('.suggestions').empty();
      
      
    }
    this.getFileFieldArea().addClass('hidden');
    switch(this.getCommandValue()) {
      case "image": 
        this.getFileFieldArea().removeClass('hidden');
        break;
      case "invite":
      case "email":
        this.setLabel("Send to (email address)");
        break;
      case "tags":
        this.setLabel("Enter as many tags as desired, comma separated");
        break;
      case"description":
        break;
      case "localize":
        if(reset == true) { this.setInput($('title').getProperty('value'));}
        this.getSuggestions();
        break;
      case "search":
      case "find":
        if(reset == true) { 
          this.setInput($('context').getProperty('value'));
        }
        this.setLabel('Drag and drop any of those');
        this.getSuggestions();
        break;
      case "address":
        break;
      case "edit":
        if(reset == true ) {
          this.setInput(this.el.getParent('.box').getElement('.editable').get('text'));
        }
        break;
      default:
        
        if(this.isInUse()){
          this.getSuggestions();
        }
    }
  },
  
  setLabel:function(label) {
    $('info_label').setProperty('text',label);
  },
  
  setInput:function(input) {
    $('input').setProperty('value', input)
  },
  
  show:function() {
    this.el.removeClass('hidden');
    $('input').focus(); 
  },
  
  spinner:function() {
    return this.el.getElement('.spinner');
  },
  
  submit:function(url) {
    var obj = this;
    if(this.getCommandValue() == 'search') {
      this.el.getElement('form').submit();
    } else {
      
      var call = new Request.HTML({
               url:url,
               // 'update':$('content'),

               onSuccess:function(a,b,c,d) {
                   if(obj.options['updated'] == 'content') {
                     if($('content').hasClass('list_mode')) {
                         $('item_list').adopt(a);
                         var t = new ListBox($('item_list').getChildren().getLast());
                     } else {

                       var col =  $("column_"+(($('content').getElements('.box').length)%4))
                       col.adopt(a);
                       
                       var t = new ListBox(col.getChildren().getLast());

                     }

                   } else {
                     $(obj.options['updated']).empty();
                     $(obj.options['updated']).adopt(a);
                   }
                   obj.fireEvent('success')
               },
               'headers':{'enctype':'multipart/form-data'},
               evalScripts:true,
               'evalResponse':true

               },this).post(this.el.getElement('form'));
    }
    
   
  },
  
  suggest:function(url) {
    url = url || this.suggestUrl();
    this.options['call'] = new Request.HTML({
      'url':url,
      'update':$('suggestions'),
      'cancel':true,
      'autoCancel':true,
      'cancelBubble':true,
      'onSuccess':this.addSuggestionsBehaviors.bind(this),
      'onComplete':this.onSuggestComplete.bind(this)
    }, this).post(this.el.getElement('form'));  
  },
  
  suggestUrl:function() {
    var url = $('suggestions').getProperty('title')+"/"+$('command').getProperty('value')+"/"+this.getInputValue();
    if($('tagging') != null) { url += "?id="+$('tagging').getProperty('value'); }
    return url;
  }, 
  
  submitUrl:function() {
    return this.el.getElement('form').getProperty('action');
  }
  
  
  
});
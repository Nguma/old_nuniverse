var Input = new Class({
  initialize:function(el) {
    this.el = el;
    if(this.el != undefined) {
      this.setBehaviors();
    }
    
  },
  
  onKey:function(key) {
    if(this.el.hasClass('disabled')) return;
     switch(key){
        case "esc":
          this.hide();
          break;
        case "enter":
          if(this.getCommandValue() == "invite") {
            if($('extra_input').hasClass('hidden')) {
              $('extra_input_label').set('text','Add a personal note or Press enter to send');
              $('extra_input').removeClass('hidden');
              $('extra_input').focus();
            } else {
              this.submit();
            }
          } else {
            this.submit();
          }
          //           } else if(!isDoubleEnter() && !$('extra_input').hasClass('hidden'))
          //           {
          //             $('input_info').set('text','Are you done? Press Enter');
          //             $('extra_input').setProperty('rows', (Number($('extra_input').getProperty('rows'))+1));


          break;
        default:
          
          if(this.isInUse()) {
            this.setCommandDisplay();
            //this.getSuggestions();
          }
          
      }
  },
  
  isInUse:function(){

   if(this.getCommandValue() == null) return false
   if(this.getInputValue().length <= 2) return false 
   return true
  },
  
  getSuggestions:function() {
    var call = new Request.HTML({
      'url':this.suggestUrl(),
      'update':$('suggestions'),
      'autoCancel':'true'
    }).get();
  },
  
  submit:function() {
    this.el.getElement('form').submit();
  },
  
  getInputValue:function() {
    return $('input').getProperty('value');
  },
  
  getCommandValue:function() {
    var match = $('command').getProperty('value').match(/^(New\s)?(\b.+\b)$/);
    if(match != null) {
      return match[2];
    } else {
      return null;
    }
    
  },
  
  getBodyValue:function() {
    return $('extra_input').getProperty('value');
  },
  
  getFileField:function() {
    return $('image_url_uploaded_data');
  },
  
  getFileFieldArea:function() {
    return $('file_field');
  },
  
  getCommandField:function() {
    return $('command');
  },
  
  setCommand:function(command) {
    this.getCommandField().setProperty('value', command);
  },
  
  setLabel:function(label) {
    $('info_label').setProperty('text',label);
  },
  
  setInput:function(input) {
    $('input').setProperty('value', input)
  },
  
  infoValue:function(val) {
    if(val != undefined) {
      $('input_info').set('text',val);
    }
    return $('input_info').get('text');
  },
  
  suggestUrl:function() {
    var url = $('suggestions').getProperty('title')+"/"+this.getCommandValue()+"/"+this.getInputValue();
    if($('tagging') != null) { url += "?id="+$('tagging').getProperty('value'); }
    return url;
  }, 
  
  hide:function() {
    this.el.addClass('hidden');
  },
  
  show:function() {
    this.el.removeClass('hidden');
    $('input').focus(); 
  },
  
  expand:function(command) {
    this.setCommand(command);
    this.setInput("");
    this.setCommandDisplay();
    $('input').focus();    
    if(this.el.hasClass('hidden')) {
      this.show();  
      return true;
    }
    return false;
  },
  
  setBehaviors:function() {
    this.getFileField().addEvents({
      'change':this.submit.bind(this)
    },this);
    this.getCommandField().addEvent('change', this.setCommandDisplay.bind(this));
  },
  
  setCommandDisplay:function() {
    $('suggestions').empty();
    this.getFileFieldArea().addClass('hidden');
    switch(this.getCommandValue()) {
      case "image":
        this.getFileFieldArea().removeClass('hidden');
        break;
      case "invite":
      this.setLabel("Send this invite to (email address)")
        break;
      case "localize":
        this.setInput($('title').getProperty('value'));
        this.getSuggestions();
        break;
      case "address":
        break;
      default:
        if(this.isInUse()){
         this.getSuggestions();
        }
    }
  },
  
  
  
});
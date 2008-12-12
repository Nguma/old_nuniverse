window.addEvent('domready',reset);
// var windowScroll;
// var inputBox;
var preview_box;
function reset()
{
 

  $$('.connection').each(function(box,i) {
      var b = new Box(box);
  });
  
  var searchBox = createSearchForm($('search_form'));
  
  var filterBox = createFilterBox($('search_box'));

  
  $$('div#tag_cloud a').each(function(tag) {
    tag.addEvent('click', function(ev) {
      ev.preventDefault();
      $('search_box').getElement('.main_input').setProperty('value', tag.get('text'));
      if($chk($('tag_cloud').getElement('.selected'))) {
        $('tag_cloud').getElement('.selected').removeClass('selected');
      }
      tag.toggleClass('selected');
      filterBox.callRequest({'delay':0});
    })
  })


  
  
  notice();
 
  

 

 $$('a#perspective_link').each(function(lnk) {
   lnk.addEvent('click',function(ev){
     ev.preventDefault();
     $('perspectives').toggleClass('expanded');
   });
 });

 

  var account = new Steppable('select_profile_form', {
    
    onTrigger:function(t) {
      this.request.options.update = this.el.getElement('.dynamic_area');
      this.callRequest({url:t.get('href')})
    }
  });
  
  var groups = new Steppable('select_groups_form', {

    'onKeyUp':function(key) {
      this.request.options.update = this.el.getElement('.suggestions');
      this.options.spinner = this.request.options.update.getPrevious('.spinner')
      this.mode = "suggest"
      this.callRequest({url:this.listener.get('src')});
    },
    
    
    'onSuccess':function() {
      this.setTriggers(this.request.options.update);
      this.setKeyListener(this.request.options.update.getElement('input#input'));
    },
    
    onTrigger:function(t) {
      if(t.getProperty('href') == '#') {
        if($chk(t.getParent('.option'))) {
          this.el.getElement('.selected_items').adopt(t.getParent('.option'));
        } 
        this.el.getElement('.suggestions').empty();
        this.listener.set('value','');
        this.mode = "regular"
      } else {
        this.callRequest({url:t.get('href'), update:this.el.getElement('fieldset')});        
      }

    }
  });
  
  if($chk($('preview_box'))) {
    preview_box = new PopUp('preview_box', {
       draggable:true,
       spinner:$('preview_box').getElement('.spinner'),
       update:$('preview_box').getElement('.content'),
       offset:{x:30,y:110},
       onExpand:function() {

       },

       onTrigger:function(t) { 
             
         if(t.hasClass('title')) {
           window.location = t.get('href');
         } else if(t.getProperty('href') != '#') {
 
           this.callRequest({url:t.get('href'), update:this.el.getElement('.content')});
         } else {
           
           switch(t.get('mode')) {
               case "tag":
                 this.addTag(this.el.getElement('.input').get('value'))
                 break
               case "untag": 
        
                 this.removeTag(t);
               break; 
               default:
                 console.log(t.get('mode'))

             }
         }

       },

       onEnter:function() {

          if(this.listener.get('mode') == "tag") {
            this.addTag(this.listener.get('value'))
          }
       },

       onSuccess:function(updated) {
   
         if($defined(this.el.getElement('.map'))){
           var funcName = 'display_'+this.el.getElement('.map').get('id');
           eval(funcName).delay(200);
         }

         this.setTriggers(this.content);
         
         this.expand();
         this.setKeyListener(updated.getElement('.input'));
       }

     });
     
  }
  
  
  $$('.tag_form').each(function(form) {
    var c = new Steppable(form, {
      spinner:form.getElement('.spinner'),
      listener:form.getElement('.input'),
      onTrigger:function(t) {
        this.mode = t.get('mode');
        
        this.request.options.update = this.el.getElement('.response')
        this.callRequest({url:t.get('href')});
        if(this.mode == "remove") {
          t.getParent('.tag').destroy();
        }
      },
      
      onSuccess:function(updated) {
        switch(this.mode) {
          case "add":
            this.setTriggers(updated);
            this.el.getElements('.tags').adopt(updated.getElements('.tag')[0], 'bottom');
            
            break;
          case "remove":
            
            break;
        }
        
      }
    });
  }); 
 
  
  
  $$('.connect_form').each(function(form) {
    var c = new Steppable(form, {
      
      spinner:form.getParent().getElement('.spinner'),
      update:form.getPrevious('.response'),
      listener:form.getElement('.input'),
      
      onTrigger:function(t) {
        this.mode = t.get('mode');

        if(t.getProperty('href') != '#') {
          
          switch(this.mode) {
            case "suggest":
            
              // preview_box.el.getElement('.data').set('html',this.el.getElement('fieldset').get('html'));
            case "connect":
              this.callRequest({url:t.get('href')});
              this.collapse();
              break;
            case "create":
              preview_box.callRequest({url:t.get('href')});
              this.reset();
            break;
            
            default:
              this.callRequest({url:t.get('href')});
              this.collapse();
               // 
              
          }
        } else {
          
          switch(this.mode) {
            case "tag":
              this.addTag(t.get('text'));
              break;
            case "untag":
              this.removeTag(t);
              break;
          }
        }
     
      },

      onExpand:function() {
        this.el.getPrevious('.response').empty();
      },

      onSuccess:function(updated) {
       
        switch(this.mode) {
          case "suggest":
            updated.getElements('.box').each(function(box) {
              var b = new Box(box);
            });
            var input = this.request.options.update.getElement('.input');
            if($chk(input)) {
               this.setKeyListener(input);
            }
            
            break;
          case "connect":
          case "image":
          case "bookmark":

            this.collapse();
            // filterBox.callRequest();
            preview(updated);
            updated.empty();
            
            filterBox.callRequest.delay(200, filterBox, {delay:200});
            break;
          default:
      
            this.collapse();
            filterBox.callRequest.delay(200, filterBox, {delay:200});
        }
        
        this.setTriggers(this.request.options.update);
    
       
      },
      
      onKeyUp:function(key) {
        if(this.el.getElement('.suggestions')) {
          this.request.options.update = this.el.getElement('.suggestions');
          this.options.spinner = this.request.options.update.getPrevious('.spinner')
          this.mode = "suggest"
          this.callRequest({url:this.el.getElement('form').get('action')});
        }
        

      }
      
    });
    
    $$('a#'+form.getProperty('id').replace(/_form/, '_lnk')).each(function(lnk) {
  
      lnk.addEvent('click', function(ev) {
        ev.preventDefault();
        var previous = $('main_menu').getElement('.activated');
        
        lnk.getParent().toggleClass('activated');
        c.toggle();

        if($chk(previous) && (previous != lnk.getParent())) { 
          previous.removeClass('activated');
          $(previous.getElement('a.expand_lnk').getProperty('id').replace(/_btn|_lnk/,'_form')).addClass('hidden');
        }
      });
    });
    
    
    
  });
  
}

function addElement(el) {
  
  var count = $('content').getElements('.box').length;
  var cols = $('content').getElements('.column').length;  

  if (cols == 0) {
    var selected_column =  $('content');
  }  else {
    var selected_column =  $('column_'+((count)%cols));
  } 
  
  selected_column.adopt(el);
  var b = new Box(selected_column.getLast('.box'));
  $('suggestion_box').getElement('.suggestions').empty();
  $('suggestion_box').addClass('hidden');
  $('select_tag_form').addClass('hidden');
}

function refresh(updated) {
  updated.getElements('.kind_lnk').each(function(lnk){
    lnk.removeEvents();
    lnk.addEvent('click',function(ev) {
      ev.preventDefault();
      $('select_tag_form_kind').setProperty('value',lnk.getProperty('html'))
    })
  });
}


function onUnload() {
  //delete(inputBox);
}

function showElement() {
    $('preview').setStyle('display','block');

    var call = new Request.HTML({
      'url':this.getElement('.preview').get('text'),
      'update':$('preview')
    }).get()
}

function hideElement(item) {
  $('preview').setStyle('display','none');
}

function onunLoad()
{
  window.document.getElements().each(function(el){
    el.destroy();
  });
  windowScroll.destroy();
  inputBox.destroy();
}

function notice(msg, classes)
{
  $('notice').removeProperty('classes');
  if($defined(classes)) {
    $('notice').addClass(classes);
  }
  if($defined(msg)) {$('notice').set('html',msg)}
  if($('notice').get('html').length <= 1) {
    $('notice').addClass('hidden');
    $('notice').setProperty('opacity',0);
  }
  else
  {
    $('notice').removeClass('hidden');
    $('notice').setProperty('opacity',1);
    $('notice').fade.delay('5000',$('notice'),'out');
  }
  
  
}

function debug(msg)
{
  console.log(msg);
}

function onAvatar(img)
{
  $('image').set('html',img)
}

function isDoubleEnter() {
  var str = $('extra_input').getProperty('value')
  if(str.substr(-1,1) == '\n') { return true;}
  return false;
}

function preview(el) {
    preview_box.setContent(el);
    preview_box.expand();
}

function createFilterBox(el) {
  if(!$chk(el)) return null;

  return new Input(el, {
        update:$('content'),
        spinner:$('main_spinner'),
        listener:el.getElement('.main_input'),
        requestUrl:el.getElement('form').getProperty('action'),
        onRequest:function() {

          $('content').empty();
        },
        
        onSuccess:function(updated) {
          updated.getElements('.connection').each(function(box) {
            var b = new Box(box);
          });
        },
        
        onKeyUp:function(key, field) {
          this.callRequest();
        },
        
        onClear:function(input) {
          this.callRequest();
        }
  });
}

function createSearchForm(form) {
  if(!$chk(form)) return null;
  return new Input(form, {
    
    listener:form.getElements('input.main_input')[0],
    update:form.getElement('.suggestions'),
    spinner:form.getElement('.spinner'),
    onKeyUp:function(input, field) {
      field.addClass('filled');
      this.callRequest({url:form.getElement('form').get('action')});
    },
    
    onClear:function(field) {
      field.removeClass('filled');
    },
    
    onTrigger:function(t) {
      this.reset();
      preview_box.callRequest({url:t.get('href')});
    },
    
    onSuccess:function(updated) {
      this.setTriggers(updated);
     
    }
  });
}
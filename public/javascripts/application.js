window.addEvent('domready',reset);
// var windowScroll;
// var inputBox;
var preview_box;
function reset()
{
 
  $$('.connection').each(function(box,i) {
      var b = new Box(box);
  });
  
  if($('search_box') != undefined) {
    var searchBox = new Input($('search_box'), {
          update:$('content'),
          spinner:$('main_spinner'),
          requestUrl:$('search_box').getElement('form').getProperty('action'),
          onRequest:function() {
            // $('preview_box').collapse();
            $('content').empty();
          },
          
          onSuccess:function(updated) {
            updated.getElements('.connection').each(function(box) {
              var b = new Box(box);
            });
            
          
          },
          
          onChange:function(input) {
           
            input.removeClass('empty');
            this.callRequest();
          },
          
          onClear:function(input) {
           
            input.addClass('empty');
            this.callRequest();
          }
    });
  }
  
  $$('div#tag_cloud a').each(function(tag) {
    tag.addEvent('click', function(ev) {
      ev.preventDefault();
      $('search_box').getElements('.input')[0].setProperty('value', tag.get('text'));
      if($chk($('tag_cloud').getElement('.selected'))) {
        $('tag_cloud').getElement('.selected').removeClass('selected');
      }
      tag.toggleClass('selected');
      searchBox.callRequest({'delay':0});
    })
  })


  
  
  notice();
 
  

 

 $$('a#perspective_link').each(function(lnk) {
   lnk.addEvent('click',function(ev){
     ev.preventDefault();
     $('perspectives').toggleClass('expanded');
   });
 });
 
 $$('a#save_perspectives').each(function(btn) {
   btn.addEvent('click',function(ev) {
     ev.preventDefault();
     var favorite_ids = $('favorite_perspectives').getElements('a.perspective').map(function(item) {return item.getProperty('alt')})
     window.location = btn.getProperty('href')+'?favorite_ids='+favorite_ids
   });
 });
  
 $$('a.perspective').each(function(lnk){
   if(!lnk.hasClass('locked')) {

      lnk.makeDraggable({
        droppables:$('perspectives'),
        
        onBeforeStart:function(el) {
          el.store('origin',el.getCoordinates(el.getParent()));
        },
        
        emptyDrop:function(el) {
        },
        
        onEnter:function(el, droppable) {
          el.removeClass('trashable');
        },
        
        onLeave:function(el, droppable) {
           el.addClass('trashable');
        },

        onDrop:function(el,droppable) {
          
          if($defined(droppable)) {
                el.setStyles({
                   'top':Math.floor((el.getCoordinates(droppable).top + 22)/55) * 55,
                   'left':Math.floor((el.getCoordinates(droppable).left + 22)/ 55) * 55,
                   'position':'absolute'
                })

          } else {
            el.destroy();

          }

        }
      });


    }


   
   
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
      } else {
        this.callRequest({url:t.get('href'), update:this.el.getElement('.content')});  
      } 
      
    },
    
    onUpdate:function() {
      
      
      
    },
    
    onSuccess:function() {
      if($defined(this.el.getElement('.map'))){
        var funcName = 'display_'+this.el.getElement('.map').get('id');
        eval(funcName).delay(200);
      }
      
      this.setTriggers(this.content);
      // this.expand();
    }

  });
  
  
  $$('.connect_form').each(function(form) {
    var c = new Steppable(form, {
      
      spinner:form.getParent().getElement('.spinner'),
      
      listener:form.getElement('.input'),
      
      onTrigger:function(t) {
        this.mode = t.get('mode');

        if(t.getProperty('href') != '#') {
          this.request.options.update = this.el.getPrevious('.response');
          this.el.addClass('hidden');
          this.callRequest({url:t.get('href')})
         
          
        }
      },

      onExpand:function() {
        this.el.getPrevious('.response').empty();
      },

      onSuccess:function(updated) {
        // $('suggestion_box').removeClass('hidden');
       
        
        
        
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
        
            
            preview(updated);
            
            updated.empty();
            break;
          default:
            
        }
        
        this.setTriggers(this.request.options.update);
    
       
      },
      
      onKeyUp:function(key) {
        if(this.el.getElement('.suggestions')) {
          this.request.options.update = this.el.getElement('.suggestions');
          this.options.spinner = this.request.options.update.getPrevious('.spinner')
          this.mode = "suggest"
          this.callRequest({url:'/tags/suggest'});
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
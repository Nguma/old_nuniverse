window.addEvent('domready',reset);
// var windowScroll;
// var inputBox;
function reset()
{
  // var r = new MooRainbow('myRainbow', {
  //    'startColor': [58, 142, 246],
  //  });
  Element.implement({
    call:function(updated) {
  
      var req = new Request.HTML({
        url:this.getProperty('href'),
        update:updated,
        onSuccess:function() {
          
        }
      }).get();
    }
  });
  
 
  
  $$('div#preview_box').each(function(el){ var popup = new PopUp(el, {draggable:true})});
 
  $$('.box','.list').each(function(box,i) {
    if(box.hasClass('list')) {
      var b = new ListBox(box);
    } else { 
      var b = new Box(box);
    }
  });
  
  
  $$('div#search_box').each(function(form) {
    var searchBox = new Input(form, {
      update:$('content'),
      suggestUrl:form.getElement('form').getProperty('action'),
      onRequest:function() {
        $('preview_box').collapse();
        $('content').empty();
      },
      
      onUpdate:function(updated) {
        updated.getElements('.box').each(function(box) {
          var b = new Box(box);
        });
      
      },
      
      onChange:function(input) {
        console.log("CHANGE")
        input.removeClass('empty');
      },
      
      onClear:function(input) {
       
        input.addClass('empty');
      }
    })
  });


  
  
  notice();
 
  
  // $$('.save_button').each(function(button) {
  //    button.addEvent('click', function(ev) {
  //      var call = new Request.HTML({
  //        'url':button.getParent('.actions').getElement('form').getProperty('action'),
  //        'onComplete':function() {
  //          button.addClass('.saved');
  //          notice("Bookmarked!");
  //        }
  //      }).post(button.getParent('.box').getElement('form'));
  //      return false;
  //    });
  //  });
 

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
 
  $$('a.select_form_lnk').each(function(lnk) {
    lnk.addEvent('click', function(ev) {
      ev.preventDefault();
      
      var form =$(lnk.getProperty('id').replace(/_btn|_lnk/,'_form'))   
      form.setStyles({
        "top":100,
        "left":200
      });
      form.removeClass('hidden');
    });
  });

  
  
  updateForms();

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


function updateForms() {
  
  $$('div.form_box').each(function(form) {
    if(form.getElement('.suggestions') == undefined) {return}
    var form_box = new Input(form, {
      update:form.getElement('.suggestions'),
      suggestUrl:form.getElement('.suggestions').getProperty('src'),
      // draggable:true,
      onRequest:function() {
        
      },
      
      onSuggestionClick:function(connection) {
        connection.getElement('.data').clone().replaces(form.getElement('form .data'));
        if(form.hasClass('inline'))
        {
          var call = new Request.HTML({
            url:form.getElement('form').getProperty('action'),
            evalScripts:true,
            onSuccess:function(a,b,c,d) {
              var count = $('content').getElements('.box').length;
              var cols = $('content').getElements('.column').length;     
              var selected_column =  $('column_'+((count)%cols));
              selected_column.adopt(a);
              var b = new Box(selected_column.getLast('.box'));
            }
          }).post(form.getElement('form'));
        }
        else
        {
          form.getElement('form').submit();
        }

      },
      
      onUpdate:function() {
        
        this.setSuggestions();
      }
      
    });
    

   

  
    
  });
  

}


function preview(el) {
    var preview_area = $('preview_box').getElement('.wrap');
  
    preview_area.empty();
    preview_area.set('html',el.get('html'));
   
    if($defined(el.getElement('.preview_url'))) {
      var call = new Request.HTML({
        'url':el.getElement('.preview_url').getProperty('href'),
        'update':preview_area.getElement('.content'),
        'onSuccess':function() {
          preview_area.getElements('.pagination a').each(function(lnk) {
            lnk.addEvent('click', function(ev) {
              ev.preventDefault();
              lnk.call(preview_content);
            });
          });
        }
      }).get();
    }
    
    if($defined(preview_area.getElement('.categorize_url'))) {
     preview_area.getElement('.categorize_url').addEvent('click', function(ev) {
        ev.preventDefault();
        this.call(preview_area.getElement('.content'));

      })
    }
    
    if($defined(el.getElement('.map'))){
      var funcName = 'display_'+el.getElement('.map').getProperty('id');
      eval(funcName).delay(200);
    }
    
    if(el.getElement('.add_to_fav_lnk') != undefined ) {
      var lnk = el.getElement('.add_to_fav_lnk').replaces($('add_to_fav_btn'));
      lnk.setProperty('id','add_to_fav_btn');
      lnk.removeClass('hidden');
    } 
    $('preview_box').removeClass('hidden');
}
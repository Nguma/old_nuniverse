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
  })
  
  $$('div#preview_box').each(function(el){var popup = new PopUp(el, {draggable:true})});
 
  $$('.box','.list').each(function(box,i) {
    if(box.hasClass('list')) {
      var b = new ListBox(box);
    } else { 
      var b = new Box(box);
    }
  });
  
  
  $$('div.search_box').each(function(form) {
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
      
      }
    })
  });


  
  
  notice();
 
  
  $$('.save_button').each(function(button) {
    button.addEvent('click', function(ev) {
      var call = new Request.HTML({
        'url':button.getParent('.actions').getElement('form').getProperty('action'),
        'onComplete':function() {
          button.addClass('.saved');
          notice("Bookmarked!");
        }
      }).post(button.getParent('.box').getElement('form'));
      return false;
    });
  });


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
      form.getElement('input.input').focus();
    });
  });
 
 $$('div#perspective_hat').each(function(div){
   div.addEvent('click', function(ev){
     div.getParent().toggleClass('expanded');
   })
 });
 
 
 $$('div#favorite_perspectives .perspective').each(function(lnk,i){

   var empty_slot = $('favorite_slot_'+(i));
  
   lnk.setStyles(empty_slot.getCoordinates($('favorite_perspectives')));
   empty_slot.removeClass('empty_slot');
 })
 
  if($defined($('control_panel'))) {
    $('control_panel').getElements('.command').each(function(command) {
       command.addEvents({
         click:function(ev) {
           ev.preventDefault();
           inputBox.expand(command.getProperty('href'), command.getProperty('title'));
         }
       });
     });
  }
  
  if($defined($('nav'))) {
    $('nav').getElements('.command').each(function(command) {
       command.addEvents({
         click:function(ev) {
           ev.preventDefault();
           inputBox.expand(command.getProperty('href'), command.getProperty('title'));
         }
       });
     });
  } 
  
  updateForms();

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
    

   
       var cancel_btn = form.getElement('.cancel_button');
       cancel_btn.removeEvents();
       cancel_btn.addEvent('click', function(ev){
         ev.preventDefault();
         form.toggleClass('hidden');
       });
  
    
  });
  

}


function preview(el) {

    var clone = el.getElement('.connection').clone();
    var preview_content = $('preview_box').getElement('.content');
    var preview_title = $('preview_box').getElement('.title');
    
    preview_title.empty();
    preview_content.empty();
    preview_title.adopt(clone);
   
    if($defined(el.getElement('.content')))
    {
      preview_title.addClass('hidden');
      preview_content.set('html',el.getElement('.content').get('html'))
    } else {
      preview_title.removeClass('hidden');
      var call = new Request.HTML({
        'url':el.getElement('.preview_url').getProperty('href'),
        'update':preview_content,
        'onSuccess':function() {
          preview_content.getElements('.pagination a').each(function(lnk) {
            lnk.addEvent('click', function(ev) {
              ev.preventDefault();
              lnk.call(preview_content);
            });
          });
        }
      }).get();
    }  
    
    if(el.getElement('.add_to_fav_url') != undefined ) {
      $('add_to_fav_btn').removeClass('hidden');
      $('add_to_fav_btn').setProperty('href',el.getElement('.add_to_fav_url').getProperty('href'));
    } else {
      $('add_to_fav_btn').addClass('hidden');
    }
    $('preview_box').removeClass('hidden');
}

                 
                    // suggestion.makeDraggable({
                    //                      droppables:form,
                    //                      onDrop:function(el,droppable) {
                    //                        if(!$defined(droppable)){
                    //                           $('content').adopt(el);
                    //                           el.setStyles({'left':0,'top':0,'height':50,'width':300})
                    //                        }
                    //                      },
                    //                      onStart:function(el){
                    //                        el.addClass('dragged');
                    //                      },
                    //                      onStop:function(el) {
                    //                        el.removeClass('dragged');
                    //                      },
                    //                      onEnter:function(el,droppable) {
                    //                         el.removeClass('droppable');
                    //                        
                    //                      },
                    //                      onLeave:function(el,droppable) {
                    //                       
                    //                        el.addClass('droppable');
                    //                      }
                    //                    });


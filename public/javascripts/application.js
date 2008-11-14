window.addEvent('domready',reset);
var windowScroll;
var inputBox;
function reset()
{
  var r = new MooRainbow('myRainbow', {
  		'startColor': [58, 142, 246],
  	});
  
  
  windowScroll = new Fx.Scroll($(document.body), {
    offset:{'x':0,'y':-200}
  });
 
  $$('.box','.list').each(function(box,i) {
    if(box.hasClass('list')) {
      var b = new ListBox(box);
    } else { 
      var b = new Box(box);
    }
  });
  

  if($defined($('input_box'))){
    inputBox = new Input($('input_box'));
    window.document.addEvent('keyup',function(ev){
      inputBox.onKey(ev.key);
    });
  }
  
  
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

function notice(msg)
{
  if($defined(msg)) {$('notice').set('text',msg)}
  if($('notice').get('text').length <= 1) {
    $('notice').addClass('hidden');
  }
  else
  {
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
    
    var input = form.getElement("input.input");
   
    if($defined(input))
    {
      input.removeEvents();
      input.addEvents({
         'focus':function() {
           input.store('focused', true);
         },

         'blur':function() {
           input.store('focused', false);
          
         },
         
         'keyup':function() {
           if(input.retrieve('focused') == true) {
             var call = new Request.HTML({
                url:form.getElement('.suggestions').getProperty('src'),
                update:form.getElement('.suggestions'),
                onSuccess:function() {
                
                  form.getElements('.connection').each(function(suggestion) {
                    suggestion.removeEvents();
                    if(suggestion.getElement('a').getProperty('href') != "#") {
                        
                      suggestion.addEvent('click', function(ev) {
                        ev.preventDefault();
                        var call = new Request.HTML({
                          url:suggestion.getProperty('href'),
                          update:form,
                          onSuccess:function() {
                            updateForms();
                          }
                        }).post(form.getElement('form'));
                      });
                    } else 
                    {
                   
                      suggestion.makeDraggable({
                        droppables:form,
                        onDrop:function(el,droppable) {
                          if(!$defined(droppable)){
                             $('content').adopt(el);
                             el.setStyles({'left':0,'top':0,'height':50,'width':300})
                          }
                        },
                        onStart:function(el){
                          el.addClass('dragged');
                        },
                        onStop:function(el) {
                          el.removeClass('dragged');
                        },
                        onEnter:function(el,droppable) {
                           el.removeClass('droppable');
                          
                        },
                        onLeave:function(el,droppable) {
                         
                          el.addClass('droppable');
                        }
                      });
                 
                    }

                  });
                  if($defined(form.getElement('.slots'))){
                    form.getElement('.slots').adopt(suggestion);
                  }
                }
              }).post(form.getElement('form'));
           }
         }

       });
       var cancel_btn = form.getElement('.cancel_button');
       cancel_btn.removeEvents();
       cancel_btn.addEvent('click', function(ev){
         ev.preventDefault();
         form.toggleClass('hidden');
       });
       
      
    }
    
  });
  
  $$('div.search_box').each(function(form) {
    
    var input = form.getElement("input.input");
   
    if($defined(input))
    {
      input.removeEvents();
      input.addEvents({
         'focus':function() {
           input.store('focused', true);
         },

         'blur':function() {
           input.store('focused', false);
          
         },
         
         'keyup':function() {
           if(input.retrieve('focused') == true) {
             var call = new Request.HTML({
                url:form.getElement('form').getProperty('action'),
                update:$('content'),
                onSuccess:function() {
                

                }
              }).cancel().post(form.getElement('form'));
           }
         }

       });

       
      
    }
    
  });
}


window.addEvent('domready',reset);
var nuniverse;
var display;
function reset()
{
  // nuniverse = new Nuniverse();
  notice();
  
  window.document.addEvent('keydown',function(ev){
    if($('input_box').hasClass('disabled')) return;
    switch(ev.key){
      case "esc":
        $('input_box').addClass('hidden');
        break;
      default:
        if($('input_box').hasClass('hidden')) {
          $('input_box').removeClass('hidden');
          $('input').focus();
        }
    }
    
  });
  
  $$('.star_rating a').each(function(star){
    var selected_stars = star.getAllPrevious().concat([star])
    star.addEvents({
      'mouseenter': function(ev) {
        selected_stars.each(function(prev){
          prev.addClass('lit');
        });
      },
      'mouseleave': function(ev) {
        selected_stars.each(function(lit) {
          lit.removeClass('lit');
        });
      }// ,
      //       'click':function(ev) {
      //         ev.preventDefault();
      //         var call = new Request.HTML({
      //           'url':star.getProperty('href')
      //         }).get();
      //         return false;
      //       }
    });
  });
  
  
  $$('.toggle').each(function(toggle) {
    toggle.addEvent('click', function(ev) {
      $('input_box').toggleClass('disabled');
      $('address_form').toggleClass('hidden');
      if(!$('address_form').hasClass('hidden')){
        $('address_form').focus();
      }
    });
  });
  
  $$('.list .items').each(function(list){
    // var sortable = new Sortables(list, {
    //      revert:{duration:500, transition:'elastic:out'},
    //      onStart:function(item) {
    //        
    //        item.addClass('dragged');
    //        
    //      },
    //      
    //      onSort:function(item) {
    //        
    //        list.getElements('.item').each(function(item,i){
    //          item.getElement('.rank').set('text', i+1);
    //        });
    //      },
    //      onComplete:function(item) {
    //        item.removeClass('dragged');
    //      }
    //    });
    
    list.getElements('.item').each(function(item){
      item.addEvents({
        'mouseenter':function() {
           item.addClass('hover');
        },
        // 'click':function() {
        //          
        //           display = showElement(item);
        //           return false;
        //         },
        'mouseleave':function() {
          item.removeClass('hover');
          // hideElement(item);
        }
      });
    });
    
  });
  
  $$('.save_button').each(function(button) {
    button.addEvent('click', function(ev) {
      button.getParent().getElement('form').submit();
      return false;
    });
  });
  


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
  nuniverse.getElements('page').destroy();
  nuniverse.el.destroy();
  nuniverse.destroy();
}

function notice(msg)
{
  if($defined(msg)) {$('notice').set('text',msg)}
  $('notice').fade.delay('5000',$('notice'),'out');
}

function debug(msg)
{
  console.log(msg);
}

function onAvatar(img)
{
  $('image').set('html',img)
}

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
  
  $$('.box').each(function(box){
    box.addEvents({
      'mouseenter':function(ev){box.addClass('hover');},
      'mouseleave':function(ev){box.removeClass('hover');}
    });
    if(box.getElement('.expander') == null) return;
    box.getElement('.expander').addEvent('click', function(ev){
      box.toggleClass('expanded');
    });
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
      $('input_box').removeClass('hidden');
      $('input').setProperty('value', toggle.getProperty('href'));
      $('input').focus();
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
  
  $$('.item .check').each(function(check){
    check.addEvent('click', function(ev){
      var connection = check.getParent('.item').getProperty('title');
      var connection_id = connection.split('_')[1]; 
      var selected_items =  Cookie.read($('nuniverse').getProperty('title'));
      selected_items = selected_items ? selected_items.split(',') : [];
      
      if(check.checked == 1) {
        selected_items.push(connection_id);
        
      } else {
        for(var k in selected_items) {
          if(selected_items[k] == connection_id) {
            selected_items.splice(k,1);
            break;
          }
        }
      }
      Cookie.write($('nuniverse').getProperty('title'), selected_items.join(','));
    })
  });
  
  // patchwork($$('.box'));
  setPagination($('nuniverse'))

}

function setPagination(source) {
  source.getElements('.pagination a').each(function(pager){
    pager.addEvent('click',function(ev){
      ev.preventDefault();
      var box = pager.getParent('.box');
      var items = box.getElement('.items');
      items.empty();
      box.addClass('loading');
      var call = new Request.HTML({
        'url':pager.getProperty('href'),
        'update':items,
        'onComplete':function(){
          box.removeClass('loading');
          setPagination(items)
        }
      }).get();
      
    });
  });
}

function patchwork(elements) {
  var cols = [0,0,0,0];
  elements.each(function(box,i){

    var x = (i%cols.length) * (box.getCoordinates()['width']+5);
    
    box.setStyles({
      'position':'absolute',
      'top':cols[i%cols.length],
      'left':x
    });
    cols[i%cols.length] += box.getCoordinates()['height'] + 5;
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

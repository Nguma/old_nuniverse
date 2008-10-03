window.addEvent('domready',reset);
var windowScroll;
function reset()
{
  
  var inputBox = new Input($('input_box'));
  windowScroll = new Fx.Scroll($(document.body), {
    offset:{'x':0,'y':-200}
  });
 
  $$('.box','.list').each(function(box,i) {
    if(box.hasClass('list')) {
      var b = new ListBox(box)
    } else { 
      var b = new Box(box)
    }
  });
  
  
  window.document.addEvent('keyup',function(ev){
    inputBox.onKey(ev.key);
  });
  
  notice();
  
  // Sets all links classed .command to open up the input and assign the correct command.
  // Expands the box if of class list.
  $$('.command').each(function(command) {
    command.addEvent('click', function(ev) {
      if(command.getParent('.box') && command.getParent('.box').hasClass('list')) {
        command.getParent('.box').addClass('expanded');
      }
      ev.preventDefault();
      inputBox.expand(command.getProperty('href'));
    });
  });
  
  $$('.save_button').each(function(button) {
    button.addEvent('click', function(ev) {
      var call = new Request.HTML({
        'url':button.getParent('.actions').getElement('form').getProperty('action'),
        'onComplete':function() {
          button.addClass('.saved');
          notice("Bookmarked!")
        }
      }).post(button.getParent('.box').getElement('form'));
      return false;
    });
  });
  
  var cards = $$('.card');
  
  cards.each(function(card){
    // var cardDrag = new Drag.Move(card, {
    //       snap:50,
    //       droppables:cards,
    //       onDrop:function() {
    //         
    //       },
    //       onEnter:function(el,droppable){
    //         el.setStyle('background-color','#9F0')
    //       },
    //       
    //       onStart:function(el){
    //         el.setStyle('z-index', 234567890)
    //       },
    //       
    //       onComplete:function(el) {
    //         
    //       }
    // });
  });
  // if($defined($('content.content_card'))) {
  //     
  //     var sortable = new Sortables($('item_list'), {
  //       constrain:true,
  //       clone:false,
  //       revert:true,
  //       onStart:function(item) {
  //         item.addClass('dragged');
  //       },
  //       onSort:function(item) { 
  //         // this.getElements('.item').each(function(item,i){
  //           // item.getElement('.rank').set('text', i+1);
  //         // });
  //       },
  //       onComplete:function(item) {
  //         item.removeClass('dragged');
  //       }
  //     });
  //   }

}


function onUnload() {
  delete(inputBox);
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

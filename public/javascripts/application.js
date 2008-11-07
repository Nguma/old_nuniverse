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
  
  inputBox = new Input($('input_box'));
  window.document.addEvent('keyup',function(ev){
    inputBox.onKey(ev.key);
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
  
 $$('a.perspective').each(function(lnk){
   lnk.addEvents({
     'mouseover':function(ev) { $('perspective_link').set('text',lnk.getProperty('title'));},
     'mouseout':function(ev) {$('perspective_link').set('text', $('perspectives').getElement('.current').getProperty('title'))}
   });
 });
 
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

window.addEvent('domready',reset);

function reset()
{
  var inputBox = new Input($('input_box'));

  $$('.box').each(function(box,i) {
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
      if(command.getParent('.box').hasClass('list')) {
        command.getParent('.box').addClass('expanded');
      }
      ev.preventDefault();
      inputBox.expand(command.getProperty('href'));
    });
  });
  
  $$('.save_button').each(function(button) {
    button.addEvent('click', function(ev) {
      var call = new Request.HTML({
        onSuccess:function() {
          button.addClass('.saved');
        }
      }).send(button.getParent().getElement('form'));
      return false;
    });
  });

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
}

function notice(msg)
{
  if($defined(msg)) {$('notice').set('text',msg)}
  if($('notice').get('text').length <= 1) {
    $('notice').addClass('hidden');
  }
  else
  {
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

window.addEvent('domready',reset);
var nuniverse;
function reset()
{
  nuniverse = new Nuniverse();
  notice();


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
  $('notice').fade.delay('3000',$('notice'),'out');
}

function debug(msg)
{
  console.log(msg);
}

function onAvatar(img)
{
  $('image').set('html',img)
}
window.addEvent('domready',reset);
var nuniverse;
function reset()
{
  nuniverse = new Nuniverse();
}

function onunLoad()
{
  nuniverse.getElements('page').destroy();
  nuniverse.el.destroy();
  nuniverse.destroy();
}
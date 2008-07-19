window.addEvent('domready',reset);

function reset()
{
  var nuniverse = new Nuniverse();

  
  if($defined($('map_div')))
  {
    var map;
    if (GBrowserIsCompatible()) {
     map = new GMap2($('map_div'));
     map.addControl(new GLargeMapControl());
     map.addControl(new GMapTypeControl());
     map.addControl(new google.maps.LocalSearch(), new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(10,20)));
     }
  }
  
 
  
   // $$('.content a.toggler').each(function(action, i)
   //     {
   //       action.addEvent('click', function(ev)
   //       {
   //         action.getParent('.content').getElement('.toggable').toggleClass('hidden');
   //       });
   //     });
   //     
   //     $$('form input').each(function(input)
   //     {
   //       this.addEvent('focus', function(ev)
   //       {
   //         
   //         input.removeClass('blank');
   //       });
   //     });
}
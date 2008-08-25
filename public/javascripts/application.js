window.addEvent('domready',reset);
var nuniverse;
function reset()
{
  // nuniverse = new Nuniverse();
  notice();
  if($defined($('input'))) {
    $('input').focus();
  }

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

// function setMap(params)
// {
//   //section = params['section'];
//   var map;
//   var map_div = $('map_div');//section.getElement('.map');
//   
//   if($defined(map_div))
//   {
//    
//     if (GBrowserIsCompatible()) {
//      
//        map = new GMap2(map_div);
//        map.setCenter(new GLatLng(params['center']['latitude'],params['center']['longitude']),params['zoom']);
//        map.addControl(new GLargeMapControl());
//        //this.map.addControl(new GMapTypeControl());
//       // this.map.addControl(new google.maps.LocalSearch());
//        //this.map.addControl( new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(10,20)));
//        //console.log(params['markers'])
//        params['markers'].each(function(m)
//        {
//        
//          var marker = new GMarker(new GLatLng(m['latitude'],m['longitude']), {title:m['title'], draggable:true});
//        
//          map.addOverlay(marker);
//          GEvent.addListener(marker, "click", function() {
//              marker.openInfoWindowHtml("<h2 style='color:#333'>"+m['title']+"</h2>");
//            });
//        
//        });
//       }
//     }
// }
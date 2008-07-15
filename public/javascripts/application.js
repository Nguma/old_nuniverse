window.addEvent('domready',reset);

function reset()
{
  var nuniverse = new Nuniverse();

  
  $$('a.add').each(function(action)
  {
    action.addEvent('click', function(ev)
    {
      $('new_connection').toggleClass('hidden');  
      action.getParent('dd').toggleClass('selected');
    });
  });
  
  // if($defined($('nuniverse_body')))
  //   {
  //     var bar_slide = new Fx.Scroll($('nuniverse_body'));
  //     $$('.actions a').each(function(action, i)
  //     {
  //       action.addEvent('click', function(ev)
  //       {
  //         var previous = action.getParent('.actions').getElement('dd.selected')
  //         if($defined(previous))
  //         {
  //           previous.removeClass('selected');
  //         }
  //         action.getParent('dd').addClass('selected');
  //         var destination = $(action.getProperty('id')+"_content")
  //         bar_slide.toElement(destination);
  //       });
  //     });
  //     if($defined('sidebar_right'))
  //      {
  //     var right_slide = new Fx.Tween('sidebar_right')
  //     $$('a.more').each(function(action, i)
  //      {
  //        action.addEvent('click', function(ev)
  //        {
  //          // var destination = $('nuniverse_body').getChildren('.content')[i];
  //          //       
  //          right_slide.start('width', 300);
  //        });
  //      });
  //    }
  //   }
  
  
  
   
   $$('.content a.toggler').each(function(action, i)
    {
      action.addEvent('click', function(ev)
      {
        action.getParent('.content').getElement('.toggable').toggleClass('hidden');
      })
    })
 
  

  // $$('.body .content').each(function(box,i)
  //     {
  //      // col = col.mix([255,255,255,0], 50)
  //       box.addEvent('mouseover', function()
  //       {
  //         this.addClass('hover');
  //       });
  //       
  //       box.addEvent('mouseout', function()
  //       {
  //         this.removeClass('hover');
  //       });
  //       
  //   });
  
  
    
}
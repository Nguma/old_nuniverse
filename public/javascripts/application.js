window.addEvent('domready',reset);

function reset()
{
  $$('.filters dt').each(function(filters)
  {
    filters.addEvent('click',function(ev)
    {
      this.getParent('.filters').toggleClass('expanded');
    });
  });
  
  var bar_slide = new Fx.Scroll($('nuniverse_body'));
  $$('.actions a').each(function(action, i)
  {
    action.addEvent('click', function(ev)
    {
      var previous = action.getParent('.actions').getElement('dd.selected')
      if($defined(previous))
      {
        previous.removeClass('selected');
      }
      action.getParent('dd').addClass('selected');
      var destination = $(action.getProperty('id')+"_content")
      bar_slide.toElement(destination);
    })
  })
  
  var right_slide = new Fx.Tween('sidebar_right')
  $$('a.more').each(function(action, i)
   {
     action.addEvent('click', function(ev)
     {
       // var destination = $('nuniverse_body').getChildren('.content')[i];
       //       
       right_slide.start('width', 300);
     })
   })
   
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
  
  $$('form.dynamo').each(function(button)
  {
      button.addEvent('click', function(ev)
      {
        
        // this.getParent('form').getChild('.restricted').setProperty('value', 1);
       
        return false;
      });
  });
    
}
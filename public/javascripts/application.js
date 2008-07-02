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
      var destination = $('nuniverse_body').getChildren('.content')[i];
      bar_slide.toElement(destination);
    })
  })
  

  $$('.body .content').each(function(box,i)
    {
     // col = col.mix([255,255,255,0], 50)
      box.addEvent('mouseover', function()
      {
        this.addClass('hover');
      });
      
      box.addEvent('mouseout', function()
      {
        this.removeClass('hover');
      });
      
  });
  
  $$('form .private').each(function(button)
  {
      button.addEvent('click', function(ev)
      {
        this.getParent('form').getChild('.restricted').setProperty('value', 1);
      });
  });
    
}
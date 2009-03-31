function setEditMode() {
   $('.browse-lnk').live('click', function(ev) {
     $('body').removeClass('edit-mode');
     $('.box').draggable('disable').resizable('disable');
     $('.box').find('.editable').unbind('dblclick');
     $('.box').find('.edit').hide();
     $('.box').find('.edit-lnk').hide();
     $('.box').find('.content').show();
     $('.browse-lnk').hide('fast');
     // makeNuniverseDraggable();
      $('.box').resizable('disable').draggable('disable');

       var data = "<layout>"
       $("#nuniverse .box").each(function(i) {
         var title = $(this).find('.metadata .title').val();
         // var tags = $(this).find('input.tags').val();
         

         data += "<box type='box'><title>"+title+"</title><class></class><header><content>"+$(this).find('.wrap .content').attr('uri')+"</content><dimension><x>"+$(this).position().left+"</x><y>"+$(this).position().top+"</y><width>"+$(this).width()+"</width><height>"+$(this).height()+"</height></dimension></box>"
       });
       data += "</layout>"


       $.ajax({
         url:$(this).attr('href'),
         // contentType:'text/xml',
         type:"POST",

         data:{xml:data},
         success:function(resp) {

         }
       })
         return false;
     return false;
   });
   
   $('.build-lnk').live('click',function(ev) {
     $('.box').draggable('enable').resizable('enable');
     $('.browse-lnk').show('fast');
     $('body').addClass('edit-mode');
     
   });
  
  
  $('.theme-lnk').live('click', function(ev) {
    ev.stopPropagation();
    var box = $(this).parents('.box');
    var prev_theme = box.data('theme') || "";
    var new_theme = $(this).attr('title');
    box.addClass(new_theme).removeClass(prev_theme).data('theme',new_theme);
    return false;
  });

   $('.save-button').click(function(ev) {
     $('body').removeClass('edit-mode');

    

   })
 }
 
 function setZoom() {
   $('#nuniverse').data('zoom-level',1);
   $('#nuniverse').data('width',$('#nuniverse').width());
   $('#nuniverse').data('height',$('#nuniverse').height());

   $('#nuniverse').dblclick(function(ev) {
       level = $('#nuniverse').data('zoom-level') / 2;
       // zoom((level < 0.2) ? 2 : level);
    });

    $('#zoom-button').click(function(ev) {
      zoom(1);
      // $.scrollTo(0, {axis:'xy'})
    })
 }
 
 
 


 
 function setGrid() {
   
   
  // var it;
  //    $('#nuniverse').draggable({
  //              start:function(){
  //                $('#nuniverse').data('top', $('#nuniverse').offset().top),
  //                $('#nuniverse').data('left', $('#nuniverse').offset().left)
  //               },
  //               
  //               drag:function() {
  //                     $('#nuniverse').data('top', $('#nuniverse').offset().top),
  //                     $('#nuniverse').data('left', $('#nuniverse').offset().left)
  //               },
  //         
  //               stop:function() {
  //                 
  //                 var transX = $('#nuniverse').data('left') - $('#nuniverse').offset().left;
  //                 var transY = $('#nuniverse').data('top') - $('#nuniverse').offset().top;
  //                 var speedX = Math.min(Math.abs(transX),20);
  //                 var speedY = Math.min(Math.abs(transY),20);
  //                 var modX = (transX < 0) ? -1 : 1; 
  //                 var modY = (transY < 0) ? -1 : 1;
  //                 clearInterval(it);
  //                 
  //                 it = setInterval(function() {
  //                   
  //                   speedX -= 1;
  //                   speedY -= 1;
  //                   if(speedX >= 1) {
  //                     $('#nuniverse').css('left',$('#nuniverse').offset().left-(speedX * modX));
  //                   }
  //                   
  //                   if(speedY >= 1) {
  //                     $('#nuniverse').css('top',$('#nuniverse').offset().top-(speedY * modY));
  //                   }
  //                   
  //                   
  //                   if(speedX <= 0 && speedY <= 0) {
  //                     clearInterval(it);
  //                   }
  //                 }, 30)
  //               }
  //           });
    
    $('.tile').live('mouseover',function(ev) {
      $(this).addClass("tile-hover");
    });
    
    $('.tile').live('mouseout',function(ev) {
      $(this).removeClass("tile-hover");
    });
    
    $('.tile').live('click',function(ev) {
      
    //   $(this).parents('.box').data('connecteds').make($(this));
      // $(this).view();
      // $('#nuniverse').scrollTo($(this),{axis:'xy', duration:600, offset:-300, queue:true})
    });
    
   
    

    
    $('#menu a').draggable({
      'helper':'clone',
      'opacity':0.4,
      'revert':true, 
      'revertDuration':100,
      'cursor':'hand',
      'stop':function(ev,ui) {
        createBox($(this).attr('target'), {
          x:ui.position['left'],
          y:ui.position['top']
        });
      }
   })
    
    $('.pager').live('click',function(ev) {
      ev.preventDefault();
      var set = $(this).parent('.set');
      var container = set.parent();
     
      $.ajax({
        url:$(this).attr('href'),
        success:function(resp) {
          container.html(resp);
          return false;
        }
      })
    });
    
   $('.set').data('tile_w', $('.set').find('.tile').width());
    $('.set').data('tile_h', $('.set').find('.tile').height());
  
  $('.zoom').click(function(ev) {
    var set = $('.set')
    var z = $('#nuniverse').data('zoom') || 1;
    z = ((z/2) < 0.1) ? 1 : (z/2);
    
    $('#nuniverse').data('zoom',z) 
    set.find('.tile').css({
      'width':set.data('tile_w')*z,
      'height':set.data('tile_h')*z
     });
    set.css({'width':set.data('w')*z})
  });

  }
  
  function createBox(template,coordinates) {
     var box = $('#templates').find(template).clone(true).appendTo($('#nuniverse'));
     box.data('display', 'list');
     var hex = Math.floor(Math.random()*255*255*255).toString(16);
     while (hex.length<6) hex = "0" + hex;
     box.css({
        'position':'absolute',
        // 'background':'#'+hex,
        'top':coordinates.y,
        'left':coordinates.x
      }).droppable({
        'accept':'.connector',
        'drop':function(ev, ui) {
        }
      });
      // .draggable({handle:'.header', stack:{group:'.box',min:1}, containement:'window', 'zIndex':9999}).resizable();
      box.setEditables();

      var p = box.prev();
      if(p.length > 0) {
        p.data('connecteds', box)
      }
      return box;
   }
  
  
  function makeNuniverseDraggable() {
    $('#nuniverse').draggable({
         start:function(){
           $(this).data('top', $(this).offset('top')),
           $(this).data('left', $(this).offset('left'))
         },
    
         stop:function() {
           var speedX = 20
           var it = setInterval(function() {
             speedX -= 1;
             $('#nuniverse').css({
               'left':$('#nuniverse').offset().left+speedX
             });
             if(speedX == 0) {
               clearInterval(it);
             }
           }, 1000)
         }
       });
  }
  
  function updateBox(box, content ) {
    if(box == undefined) return false;
  
    if(content != null) {
     box.find('.wrap .content').html(content).show().movable({target:'.set'});
     box.find('.content .header').replaceAll(box.find('.wrap .header'));
     box.children('.footer').replaceAll(box.find('.wrap .footer'));
     }
    box.children('.wrap .header').show();
    box.find('.edit').hide();
    box.find('.content').movable({target:'.set'})


    
    box.createSuggestables("/");
    box.find('.content form').submit(function(ev) {
      ev.preventDefault();
      $(this).ajaxSubmit({
        success:function(resp) {
         updateBox(box,resp);
        
        }
      });
    });
  }
  
  
  
  function zoom(level) {
    var nuniverse = $('#nuniverse');
    if(nuniverse.data('zoom-level') == level) return true;
    nuniverse.data('zoom-level', level);
    nuniverse.animate({
       width:nuniverse.data('width') * level,
       height:nuniverse.data('height') * level
       // left:-($('body').scrollLeft() * level)+'px'
     });
  }
  
  // Creates and connect submenu items
  function setSubMenu(section) {
    section.find('.sub-menu').clone(true).prependTo($('#sub-menu'))
  }
  
  function setBoxes() {
    $('#grid .box').click(function(ev) {

       var prev_box = $('#grid').data('currentBox');
       var col = $(this).parents('.col');
       var box = $(this);

       if($(this) == prev_box) return;
       $('#grid').data('currentBox', box);
       box.data('baseHeight', box.height())

       $.scrollTo(box,'fast', {offset:{top:-200},onAfter:function() {
         col.siblings().animate({width:'29%'},500);
         col.stop().animate({width:'41%'},500);
         box.animate({'height':box.height()+200});
         if( prev_box && prev_box.attr('id') != box.attr('id')) {prev_box.stop().animate({'height':prev_box.data('baseHeight')},'fast')}
       }});

     });
    $('.box').bind("mouseenter", function(ev) {
       $(this).addClass('hover');

    });

    $('.box').bind("mouseleave", function(ev) {
       $(this).removeClass('hover');

    });

      $('.box').each(function() {
        $(this).data('display','list');
      })

      $('.box').find('.edit-lnk').live('click' ,function(ev) {
       ev.preventDefault();

       $(this).parents('.box').children('.wrap .header').hide();
       $(this).parents('.box').children('.wrap .content').hide();
       $(this).parents('.box').find('.edit').show();
       return false;
     });


   $('a.destroy-box-lnk').click(function(ev){
      $(this).parents('.box').remove();
      return false;
    });
  }
  // Set behaviors for each .section, making them independently scrollable
  // Deprecated
  function setSections() {
    var section =  $('#nuniverse').find('.section:first');
    $('#nuniverse').data('current_section',section);
    $('.section').movable();
  }

  // Selects the matching tab from the crumbs menu
  function selectTab(lnk) {
    var li = lnk.parent();
    if(li.length == 0) return;
    var section = $(lnk.attr('href'));
    var offsetX = 0 //($(window).width()- section.width())/2 
    $('#breadcrumbs .selected').animate({"left":li.position().left, "width":li.width()}, "slow");
    $('#nuniverse').data('current_section', section);
    $('#nuniverse').scrollTo(section, {'axis':'x', duration:500, offset:{left:-offsetX}});
  }

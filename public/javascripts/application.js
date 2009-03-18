$(window).unload(function() {
  
});

$(document).ready(function()
{
  
  // $('#nuniverse').css({'left':($(window).width() - 600)/2})
  

  
  setLocalScroll();
  setExpandLinks();
  // setConnections(); 
  setCloseButtons(); 
  setTabs();
  setBoxes();
  setImagesActions();
  setPreview();
  setSections();
  setEditMode();
  setTemplates();
  setGrid();
  
  updateView();
  // setForms();
  
  $('.input-lnk').live('click', function(ev) {
    ev.preventDefault();
    
    $('#input_form').fadeIn('fast');
    $('#input_order').attr('size',$(this).attr('href').length+3).val($(this).attr('href'));
    $('#input_value').focus();
  
  });
  
  $('#input_order').keyup(function(ev) {
    $(this).attr('size', $(this).val().length*1.5);
  });
  
  $(document).keypress(function(ev) {
    if(isValidKey(ev) && !ev.ctrlKey && !ev.shiftKey && !ev.metaKey && !ev.altKey) {
      $('#input_form:hidden').each(function() {
        $(this).fadeIn('fast');
        if(ev.which != 32) {
          var path = $('#nuniverse').data('current_section').find('.category').text();
          $('#input_value').val(path+ String.fromCharCode(ev.which)).focus();
        } else {
          $('#input_value').focus();
        }
        
        
      });
    }

    
  });
  
  
  $('#input_form').submit(function(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    var section = $('#nuniverse').data('current_section');
    
    $(this).find('.source-id').val(section.find('.source-id').val());
    $(this).find('.source-type').val(section.find('.source-type').val());
    $(this).find('#input_path').val(section.find('.path').text());
    var url = ("/"+$('#input_order').val().toLowerCase()+"/"+$('#input_value').val()+'/').replace(/\s/g,'_')
    
     $(this).ajaxSubmit({
        url:url,
        resetForm:true,
        success:function(resp) {
          
          if($(resp).find('#search-results').length == 1) {
       
            $('#suggestions').show().html($(resp).find('#search-results'));
            $('#suggestions dd').each(function(i) {
              $(this).hide().fadeIn(i*100);
            });
            $('#nuniverse').hide()
          } else {
            $(resp).find('dd').prependTo(section.find('#connections')).hide().slideDown('fast');   
            updateScore($(resp).find('#score'));
          }

        }
      });
    return false;
  });
  
   var ajax_timeout;
  $('#input_value').keypress(function(ev) {
    
   
    var el = $(this);
    var delay = 300;
    
    
    if(ev.which == 13 ) {
      ev.preventDefault();
      $(this).parents('form').submit();
      
    } else if (ev.keyCode == 27) {
      $(this).parents('form').fadeOut('fast');
    } else if(isValidKey(ev) && !ev.ctrlKey && !ev.shiftKey && !ev.metaKey && !ev.altKey) {
      if (ajax_timeout != undefined) {clearTimeout(ajax_timeout)};
      ajax_timeout = setTimeout(function() {
        suggest(el);
      }, delay);
    }
  });


  $('.connection').hover(function(ev) {
    $(this).addClass('hover');
  }, function(ev) {
    $(this).removeClass('hover');
  });
  
  
  $('.connections a.expand-lnk').live('click', function(ev) {
    $(this).parents('dl').find('.activated').removeClass('activated');
    $(this).parent('dd').addClass('activated');
    $('#left-col').animate({width:'19%'}, 'slow');
      $('#center-col').animate({width:'40.6%'}, 'fast');
      $('#right-col').animate({width:'31%'}, 'slow');
     ev.preventDefault();
     $.ajax({
       url:$(this).attr('href'),
       success:function(resp) {
         expandSection(resp);
       }
     })
   });
  //  
  
 
  
  $('#input-visit').makeSuggestable();
  $('#notice').hide();
  $('.popup').draggable();
  $('#message').hover(function(ev) {
    $(this).stop(true).show();
  }, function(ev) {
    $(this).fadeOut();
  })

  $('.set').build();
  
  // $('.cell').live('dblclick',function(ev) {
  //     var section = $(this).parents('.section');
  //     
  //     section.find('.edited-cell').each(function(ev) {
  //       var prop = 'properties['+$(this).parent().attr('label')+']';
  //       $.ajax({
  //         url:$('#cell-'+$(this).parent().attr('row')+'-1').find('a').attr('href')+'/update',
  //         type:'POST',
  //         data:{'properties[retail+price]':$(this).val()}
  //       })
  //       $(this).replaceWith($(this).val());
  //     })
  //     ev.preventDefault();
  //     ev.stopPropagation();
  //     var cell_field = $('#templates').find('.edited-cell').clone(true);
  //     cell_field.val($(this).text());
  //     $(this).html(cell_field);  
  //   });
  
  $('#view').find('.close-btn').click(function() {
    $('#nuniverse').fadeIn('fast');
    $('#view').hide();
    $('#comment-box').hide();
    $('#share-box').hide();
  });
  
  $('a.inline').live('click', function(ev) {
    ev.preventDefault();
    var target = $(this).attr('target');
    $.ajax({url:$(this).attr('href'), success:function(resp) { $(target).html(resp)}});
  });
  
  // Makes all display links switch display class for target
  // target: class name to switch to
  $('.display a').live('click',function(ev) {
    ev.preventDefault();
    var prev = $(this).parents('.box').data('display');
    var nc = $(this).attr('target');
    var set = $(this).parents('.box').find('.set');
    set.removeClass(prev).addClass(nc);
    $(this).parents('.box').data('display', nc);
    
    
  });
  
  // $('#nuniverse .wrap').css({'left':100})
  var section =  $('#nuniverse').find('.section:first');
  // section.css({'margin-left':($(window).width()- section.width())/2 })
  $('#nuniverse').data('current_section',section);
  // $('#nuniverse').scrollTo($('#nuniverse').find('.section')[1], {axis:'x', duration:500}
  
});


jQuery.fn.extend({
  // Adds suggestions feature to a field
  // Callback: Method to call when suggestion is clicked. if not set, suggestions are not ajaxed
  makeSuggestable:function(callback) {
 
    suggestions = $('#suggestions');
    var ajax_timeout, input;
    $(this).keyup(function(ev) {
      var el = $(this);
      input = $(this).val();
      if (ajax_timeout) {clearTimeout(ajax_timeout)};
      ajax_timeout = setTimeout(function() {
        suggest()

      }, 500);

    });
    
    $(this).blur(function(ev) {
      // suggestions.empty().hide();
    });
    
  },
  
  // callback: callback upon clicking on suggestion
  createSuggestables:function(callback) {
    var scope = $(this)
     $(this).find('input.suggestable').each(function() {
        $(this).makeSuggestable(function(suggestion) {
          
          $.ajax({
            url:suggestion.attr('href'),
            success:function(response){
              
              scope.replaceWith($(response));
              // scope.update(callback);
              return false;
            }
          })
          return false;
        });
      });
  },

  
  // Checks for live content
  // passes a url for calls
  update:function(url) {
    $(this).setForms();
    $(this).createSuggestables(url);
  },

  
  // previews the item in the preview box
  // clone (bool):  Clone effects or not, defaults to true
  // close (fn): fn called when preview closes
  preview:function(params) {
    
    settings = jQuery.extend({
      'clone':true,
      'close':null
    }, params);
    
    var preview = $('#preview');
    preview.find('.content').html($(this).clone(settings.clone).css({'left':'0','top':'0px'}));
    
    if($(this).attr('href')) {
        $.ajax({
          url:$(this).attr('href'),
          success:function(resp) {
            preview.find('.content').html(resp);
          }
        })
    }
  
    $('#preview:hidden').css({
      'left':($(window).width() )/2,
      'top':($(window).height() - preview.height())/2,
    }).fadeIn('fast');
  },
  
  movable:function(params) {
    
    settings = jQuery.extend({
      'axis':'y',
      'speed':20,
      // 'target':null
    }, params);
    var it;
    var el = (settings.target == null) ? $(this) : $(this).children(settings.target);
    
    el.draggable({
          axis:settings.axis,
          start:function(){
            $(this).data('top', $(this).position().top),
            $(this).data('left', $(this).position().left)
          },
    
          drag:function() {
            $(this).data('top', $(this).position().top),
            $(this).data('left', $(this).position().left)
          },
    
          stop:function() {
            
           var transX = $(this).data('left') - $(this).position().left;
           var transY = $(this).data('top') - $(this).position().top ;
           var speedX = Math.min(Math.abs(transX),settings.speed);
           var speedY = Math.min(Math.abs(transY),settings.speed);
           var modX = ($(this).data('left') < $(this).position().left) ? 1 : -1;
           var modY = ($(this).data('top') < $(this).position().top) ? 1 : -1;
           var newX = $(this).position().left + (speedX * modX);
           var newY = $(this).position().top + (speedY * modY);
           var el = $(this);
           
           clearInterval(it);
          
           it = setInterval(function() {
             
             speedX -= 1;
             speedY -= 1;
             if(speedX >= 1) {
               el.css('left',newX);
               newX += (speedX * modX)
             }
    
             if(speedY >= 1) {
                // $(this).css('top',$(this).offset().top);
               
                el.css('top', newY)
                newY +=  (speedY * modY);
             }
    
    
             if(speedX <= 0 && speedY <= 0) {
               clearInterval(it);
             }
           }, 30)
         }
         });
     return $(this)
  },
  
  saveCoordinates:function() {
     $.ajax({
        url:$(this).attr('src'),
        data:{
            'obj[width]':$(this).width(),
            'obj[height]':$(this).height(),
            'obj[y]':$(this).position().top,
            'obj[x]':$(this).position().left
        }
      })
  },
  
  build:function() {
    var cols, rows, width, height,w, h, x, y, top_value, set, offset;
    set = $(this);
    cols = set.attr('cols');
    width = set.width()/cols;
    height = set.height()/cols;
    top_value = Number(set.attr('ref'));
    offset = 2;
  
    
    $(this).find('dd').each(function(i) {
      x = i%cols;
      y = Math.floor(i/cols);
      
      
      px = (100/cols) * (x+1);
       
      $(this).css({
        'width': set.hasClass('vertical') ? 'auto': (px+'%'),
        'height':set.hasClass('vertical') ? (px+'%') : 'auto',
      });
      
      var left = set.hasClass('vertical') ? (y * ($(this).width() + offset)) : (x * width);
      var top = set.hasClass('vertical') ? (x * height) : (y * ($(this).height() + offset));
      
      $(this).css({
        'left':left,
        'top':top
      });
      
      var value = (Number($(this).find('.value').text()) * 100 ) / top_value;
      
      $(this).find('.bar').width(0).height(0).animate({
        'width': set.hasClass('vertical') ? '100%': (value+'%'),
        'height':set.hasClass('vertical') ? (value+'%') : '100%',
      }, value * 10);
     
      
    }).hover(function() {
      $(this).addClass('hover');
      $('#message').html($(this).find('.preview').clone())
      $('#message').css({
        'left':$(this).offset().left ,
        'top':$(this).offset().top
      }).fadeIn()
    }, function() {
      $(this).removeClass('hover');
      // $('#message').fadeOut('slow')
    });
    
  },
  
  setEditables:function() {
    $(this).find('.editable').dblclick(function(ev) {
      var text = $(this).text();
      var el = $(this)
      el.html('<input type="text" value="'+text+'"></input>');

      el.find('input').keypress(function(ev) {
        if(ev.which == 13 ) {
          el.html($(this).val())
        }
      })
    });
  },
  
  make:function(source) {
    $(this).find('.namespace').replaceWith(source.find('.data'));
    $(this).find('.edit form').submit();
  }
  
  

  
  
});

function setSections() {

   
  $('.section').movable();
  
}

function setBoxes() {
  $('.box').bind("mouseenter", function(ev) {
     $(this).addClass('hover');
     // $(this).find('.menu').show();
  });
  
  $('.box').bind("mouseleave", function(ev) {
     $(this).removeClass('hover');
     // $(this).find('.menu').hide();
  });
  
  
    // $('.box').draggable({'handle':'.header'}).draggable('disable');
    $('.box').each(function() {
     
      $(this).data('display','list');
      // $(this).find('.content .header').replaceAll($(this).find('.wrap .header'));
    })
    
    $('.box').find('.edit-lnk').live('click' ,function(ev) {
     ev.preventDefault();
     
     $(this).parents('.box').children('.wrap .header').hide();
     $(this).parents('.box').children('.wrap .content').hide();
     $(this).parents('.box').find('.edit').show();
     return false;
   });
   
   

     // $('.box').find('.edit form').submit(function(ev) {
     //        ev.preventDefault();
     //        var box = $(this).parents('.box');
     //        $(this).ajaxSubmit({
     //          url:"/tags/show/",
     //          update:box.children('.content'),
     //          success:function(resp){
     //           
     //          }
     //        })
     //      });
       
 $('a.destroy-box-lnk').click(function(ev){
    $(this).parents('.box').remove();
    return false;
  });
}
// 
// function scale(section) {
//   var percent_w = (section.width() * 100) / $('#nuniverse').width();
//   var percent_h = (section.height() * 100) / $('#nuniverse').height();
//   var percent_l = (section.position().left * 100) / $('#nuniverse').width();
//   var percent_t = (section.position().top * 100) / $('#nuniverse').height();
//   //     var percent_t =  (section.position().top * 100) / $(document).height();
// 
//   section.width(percent_w+'%');
//   section.height(percent_h+'%');
//   section.css('left',percent_l+'%');
//   section.css('top',percent_t+'%');
//   // section.height(percent_h);
// }


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


function setTabs() {
  $('#breadcrumbs a').live("click",function(ev) {
    ev.stopPropagation();
    ev.preventDefault();
    selectTab($(this));
    

  });
  
}


function setPreview() {
  $('#preview').draggable()
}







function expandSection(section) {
      $('#right-col').html($(section));
    // var current_section = $('#nuniverse').data('current_section');
    //   var current_lnk = $('#breadcrumbs li:has(a[href=#'+current_section.attr('id')+'])');
    //   
    //   current_section.nextAll().remove();
    //   current_lnk.nextAll().remove();
    // 
    //  
    //   new_section = $('#nuniverse').find('.section:last')
    // $(section).find('.section-lnk').appendTo($('#breadcrumbs')).wrap('<li></li>');
    
   
    
  //   selectTab($('#breadcrumbs a:last'));
    // new_section.movable()

  // var target,url,parent_section;
  //  var parent_section = connection.parents('.section');
  // 
  //  var url = connection.attr('href'); 
  //  var target = $('#'+connection.attr('target'));
    
  // 
  // 
  //  

  //  
  //  if(target.length == 0) { target = $('#section-template').clone(true).attr('id',connection.attr('target')).resizable() }
  // 
  //  parent_section.nextAll().remove();
  //  // current_lnk.nextAll().remove(); 
  //  parent_section.after(target);
  //  
  //  // target.find('.wrap .header').empty();
  //  // target.find('.wrap .content').empty();
  //  target.find('.spinner').fadeIn();
  //  target.fadeIn('fast');
  //  
  //  if(url.length > 1 && url[0] != "#") {
  //    $.ajax({
  //      url:url,
  //      success:function(resp) {
  //        // target.find('.spinner').hide();
  //        updateSection(target, resp);
  //      }
  //    });
  //  }
  //    

}



  // Update: Called after each Ajax update, to refresh updated section
  function update(section) {
    section.height($(window).height()).css('top',0);
    section.movable({target:'.content'});
    section.find('.menu a').click(function(ev) {
      $.ajax({url:$(this).attr('href')})
      return false;
    });
    
    setPagination(section);
    section.setForms();
    setSubMenu(section);
  }
  
  // Creates and connect submenu items
  function setSubMenu(section) {
 
    section.find('.sub-menu').clone(true).prependTo($('#sub-menu'))
  }
  
  // Makes all pagination links ajax.
  function setPagination(scope) {
    scope.find('.pagination a').click(function(ev) {
      return false;
    })
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

var suggest_request = null 
function suggest(el) {
  if(suggest_request) { suggest_request.abort();}
  suggest_request = $.ajax({
      url:"/suggest",
      data:{'value':el.val()},
      success:function(response) {
        $('#suggestions').html(response);
        $('#suggestions').show();
 
      }
    })
}


function setPaginationLinks(scope) {
   $('.pagination a').click(function(ev) {
      $.ajax({
        url:$(this).attr('href'),
        target:scope
      });
      return false;
    })
}




// Finds all links with class .expand-lnk and makes them call content to expand dynamically.
// it will read the following properties from each links
// target: id of the section to receive content, defaults to preview box
// href: url to call 
function setExpandLinks() {
  
  $('a.customize-lnk').live('click', function(ev) {
    ev.preventDefault();
    $(this).parents('.box').find('.content').toggle();
  
  });
  // 
  // $('a.expand-lnk').live('click',function(ev) {
  //   ev.preventDefault();
  //   $(this).preview()
  //   // expandSection($(this));
  //   return false;
  // })
}

   
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


  function setCloseButtons() {
    $(".close-btn").live("click", function(ev) {
      $(this).parent().hide(); 
      return false;
    });
    
    $(".close-lnk").live("click", function(ev) {
      $(this).parents('.box').hide(); 
      return false;
    });
  }
  
  function setImagesActions() {
    $('.image-form').submit(function(ev){
      ev.preventDefault();
      var form = $(this);
      var source = $('#'+form.find('.source-type').val()+'-'+form.find('.source-id').val());
      var box = $(this).parents('.box');
      $(this).ajaxSubmit({
          iframe:true,
          success:function(resp, form) {
            box.find('.content').html(resp);
          }
      });
      return false;
    });

    $('img.default').live("click", function(ev){
      var popup  = $('#preview');
      var connection = $(this).parents('.connection');
      connection.preview();
      popup.find('.content').append($('.image-form').clone(true));
      popup.find('input.source-id').val(connection.find('.source-id').val())
      popup.find('input.source-type').val(connection.find('.source-type').val());
      ev.stopPropagation();
      return false;
    });
  }
  
  function setLocalScroll() {
 //   $.serialScroll({target:'.section',duration:500, 'axis':'x', lazy:true})
    // $.serialScroll({axis:'x', duration:800, margin:true, queue:true, offset:{left:0,top:-80}, lazy:true});
  }

  
  jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  });
  
  $(document).ajaxSend(function(event, request, settings) {
    if (typeof(AUTH_TOKEN) == "undefined") return;
    // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
    settings.data = settings.data || "";
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
  });
  
  
  // $('.search-input').keyup(function(ev) {
  //      var target = $(this).parents('.section').children('.content');
  //      $.ajax({
  //        url:$(this).parents('form').attr('action')+'?input='+$(this).val(),
  //         success:function(response) {
  //           target.html(response)
  //           setPaginationLinks(target)
  //           
  //          }
  //      })
  //    })
  
  // $('#box-button').click(function(ev){
  //   
  //   var box = $('#box-template').clone().appendTo($('#nuniverse'));
  //   box.attr('id', "")
  //   box.show('fast').draggable().resizable({autoHide:true});
  //   return false;
  // });
  // 
  // $('#image-button').click(function(ev) {  
  //   var box = $('#image-box-template').clone().appendTo($('#nuniverse'));
  //   box.attr('id', "")
  //   box.show('fast').draggable().resizable({autoHide:true});
  //  
  //   
  //   
  //   return false;
  // });
  
  




  
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

   
   function updateView() {
     $('#view').find('a[target]').click(function(ev) {
       
       var win = $($(this).attr('target'))
       // if(win.length() == 0) {
       //          win = $('#template .box').clone(true).appendTo($(this));
       //        }
       
       if($(this).attr('href') != "") {
         $.ajax({
           url:$(this).attr('href'),
           success:function(resp) {
             win.find('.content').html(resp);
           }
         });
         
       }
       win.fadeIn('fast');
       return false;
     });
   }
   
   function setTemplates() {
     $('.datepicker').datepicker();
   }
   
   function setForms() {
     
     $('.box').find('form').submit(function(ev) {
       var box = $(this).parents('.box');
       ev.preventDefault();
       $(this).ajaxSubmit({
         success:function(resp) {
        
          updateBox(box,resp);
          
         }
       });

     });
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
   
   function updateSection(section, content) {
     // section.children('.wrap').html(content);
   
     section.animate({width:Math.min(600,section.find('.box').width())}, 'fast', 'linear');
     updateBox(section.find('.box'))
     selectTab($('#tab-menu a:last'));
     // $('#tab-menu a:last').trigger('click'); 
   }
  
  
  function isValidKey(ev) {
    keycode = (ev.which == 0) ? ev.keyCode : ev.which
    if(keycode == 32 || (65 <= keycode && keycode <= 65 + 25) || (97 <= keycode && keycode <= 97 + 25)) return true
    return false
  }
  
  
  function updateScore(score) {
    
    if(score == undefined) return
    $('#score').replaceWith(score);
   
    $('#score').hide().fadeIn('slow');
  }
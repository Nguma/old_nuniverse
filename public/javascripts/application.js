$(window).unload(function() {
  
});

$(document).ready(function()
{
  setLocalScroll();
  setExpandLinks();
  setConnections(); 
  setCloseButtons(); 
  setTabs();
  setBoxes();
  setImagesActions();
  setPreview();
  setSections();
  setEditMode();
  // setDrawables();
    // inlineFacts(window);
  setGrid();
  $(this).setForms();
  $('#input-visit').makeSuggestable();
  $('#notice').hide();
  $('.popup').draggable();
  $('#message').hover(function(ev) {
    $(this).stop(true).show();
  }, function(ev) {
    $(this).fadeOut();
  })

  $('.set').build();
  
  $('.switch-vertical').click(function() {
    $('.set').toggleClass('vertical');
    $('.set').build();
    return false;
  })
  
  $('.cell').live('dblclick',function(ev) {
    var section = $(this).parents('.section');
    
    section.find('.edited-cell').each(function(ev) {
      var prop = 'properties['+$(this).parent().attr('label')+']';
      $.ajax({
        url:$('#cell-'+$(this).parent().attr('row')+'-1').find('a').attr('href')+'/update',
        type:'POST',
        data:{'properties[retail+price]':$(this).val()}
      })
      $(this).replaceWith($(this).val());
    })
    ev.preventDefault();
    ev.stopPropagation();
    var cell_field = $('#templates').find('.edited-cell').clone(true);
    cell_field.val($(this).text());
    $(this).html(cell_field);  
  });
  
  $('#view').find('.close-btn').click(function() {
    $('#nuniverse').fadeIn('fast');
    $('#view').hide();
  });
  
});


jQuery.fn.extend({
  // Adds suggestions feature to a field
  // Callback: Method to call when suggestion is clicked. if not set, suggestions are not ajaxed
  makeSuggestable:function(callback) {
    $(this).after("<dl class='suggestions'></dl>");
    var suggestions = $(this).next();
    var ajax_timeout, input;
    $(this).keyup(function(ev) {
      input = $(this).val();
      if (ajax_timeout) {clearTimeout(ajax_timeout)};
      ajax_timeout = setTimeout(function() {
        $.ajax({
            url:"/suggest-a-nuniverse",
            dataType:'html',
            data:{'input':input},
            success:function(response) {
              suggestions.html(response);
              suggestions.show();
              if(callback != undefined) {
                suggestions.find('.suggestion').click(function(ev) {   
                  eval(callback($(this)))
                  return false;
                });
              }
            }
        });

      }, 500);

    });
    
    $(this).blur(function(ev) {
      suggestions.empty().hide();
    });
    
  },
  
  createSuggestables:function(url) {
    var scope = $(this)
     $(this).find('input.suggestable').each(function() {
        $(this).makeSuggestable(function(suggestion) {
          $.ajax({
            url:url+'?nuniverse='+suggestion.find('.unique-id').text(),
            success:function(response){
              scope.find('.content').html(response);
              scope.update(url);
              return false;
            }
          })
          return false;
        });
      });
  },
  
  setForms:function() {
    var scope = $(this);
    $(this).find('form[class=inline]').ajaxForm(function(resp) {
       scope.find('.content').html(resp);
      
    });
  },
  
  // Checks for live content
  // passes a url for calls
  update:function(url) {
    $(this).setForms();
    $(this).createSuggestables(url);
    
  },
  
  view:function(params) {
    settings = jQuery.extend({
      'clone':true,
      'close':null
    }, params);
    
    var tile = $(this);
    tile.find('.spinner').fadeIn('fast');
    
    $.ajax({
      url:tile.attr('href'),
      success:function(resp) {
        $('#view').find('.content').html(resp);
        $('#view').show();
        $('#nuniverse').fadeOut();
        tile.find('.spinner').hide();
      }
    });
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
      'target':null
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
    
  }
  

  
  
});

function setSections() {
  $('.section').movable({target:'.content'});
  $('.section').live('dblclick',function(ev) {
    if($(this).position().left == $(document).scrollLeft()) {
      // $.scrollTo($(window).scrollLeft() - 350, {duration:600, axis:'x'});
    } else {
      $.scrollTo($(this), {duration:500, axis:'x'});
      $(this).animate({'width':$(window).width()});
    }

   });
  
}

function setBoxes() {
  $('.box').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  }).live('click', function(ev) {
    // $(this).movable({target:'.content'});
  }).draggable();
  
 $('a.destroy-box-lnk').click(function(ev){
    $(this).parents('.box').remove();
    return false;
  });
}

function scale(section) {
  var percent_w = (section.width() * 100) / $('#nuniverse').width();
  var percent_h = (section.height() * 100) / $('#nuniverse').height();
  var percent_l = (section.position().left * 100) / $('#nuniverse').width();
  var percent_t = (section.position().top * 100) / $('#nuniverse').height();
  //     var percent_t =  (section.position().top * 100) / $(document).height();

  section.width(percent_w+'%');
  section.height(percent_h+'%');
  section.css('left',percent_l+'%');
  section.css('top',percent_t+'%');
  // section.height(percent_h);
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


function setTabs() {
  $('#tab-menu a').live("click",function(ev) {
    selectTab($(this));
    return false;
  });
  selectTab($('#tab-menu a[id!=logout]:second'));
}


function setPreview() {
  $('#preview').draggable()
}




  // Ajaxifies each .connections present in the scope
  function setConnections() {
       $('.connection a, .active-lnk').live('click', function(ev) {
         ev.stopPropagation();      
         goToNewSection($(this));
         
         if($(this).parents('.connection')) {
           $(this).parents('.content').find('.selected').removeClass('selected');
           $(this).parents('.connection').addClass('selected');           
         } 
         
         return false;       
       })

       $('.connection').live('mouseover', function(ev) {
         $(this).addClass('hover'); 
       }).live('mouseout', function(ev) {
         $(this).removeClass('hover');
         $('#contextual-content').hide();
       });  
  }



function goToNewSection(connection) {
    var section_id = connection.attr('target');
    if($('#'+section_id).length == 1) {
      var new_section = $('#'+section_id)
    } else  {
      var new_section = $('#section-template').clone().attr('id', section_id).width($(window).width() - 300);
    }
    
    var current_section = connection.parents('.section');
   
    var current_lnk = $('#tab-menu li:has(a[href=#'+current_section.attr('id')+'])');
     // new_section.find('.hat').html(connection.find('.body').clone().html());
     current_section.nextAll().remove();
     current_lnk.nextAll().remove(); 
     current_section.after(new_section);
     
     new_section.css('top',$(document).scrollTop()).show('fast')
     // scale(new_section)

     $('#tab-menu').append(connection.clone());
     $('#tab-menu a:last').wrap("<li></li>").attr('href','#'+new_section.attr('id'));
     
      
      
      
     $.ajax({
       url:connection.attr('href'),
       success:function(resp) {
         if($(resp).hasClass('.section')) {
           new_section.replaceWith(resp);
         } else {
           new_section.find('.content').html(resp);
         }
         $('#'+section_id).update(connection.attr('href'));
         update( $('#'+section_id));
         $('#tab-menu a:last').trigger('click');  
       }
     });
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
    $('#tab-menu .selected').animate({"left":li.position().left, "width":li.width()}, "slow");
    $('#sub-menu').empty();
    section.find('.sub-menu').clone(true).prependTo($('#sub-menu'));
    $('#nuniverse').data('section', section);
    
    section.prev().animate({width:350}, 'fast');
    section.animate({width:$(window).width() },'fast');
    if(section.attr('id') == 'overview') {
      $.scrollTo(0, {duration:700, axis:'x'});
    } else {
      $.scrollTo(section.prev(), {duration:700, axis:'x', offset:340});
    }
    

    // $.scrollTo(section.prev(), {duration:200,axis:'x',offset:340});
  }

var suggest_request = null 
function suggest(el) {
  if(suggest_request) { suggest_request.abort();}
  suggest_request = $.ajax({
      url:"/suggest-a-nuniverse",
      dataType:'html',
      data:{'input':el.val()},
      success:function(response) {
        $('#suggestions').html(response);
        $('#suggestions').show();
        $('#suggestions a').click(function(ev) {
          
        });
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




function onFormSubmit() {
   var section = $(this).parents('.section')
    $(this).ajaxSubmit({
       clearForm:true,
       beforeSubmit:function() {
         if(suggest_request) { suggest_request.abort();}
       },
       success:function(response) {
         section.find('.content-list .step:first').before(response);
         $('#suggestions').empty();
         update(section.find('.content-list .step:first'))
       }
     });
     return false;
}
  

// Finds all links with class .expand-lnk and makes them call content to expand dynamically.
// it will read the following properties from each links
// target: id of the section to receive content, defaults to preview box
// href: url to call 
function setExpandLinks() {
  
  $('a.expand-lnk').live('click',function(ev) {
    var target,url;
    
    url = $(this).attr('href'); 
    if ($(this).attr('target')) {
      target = $('#'+$(this).attr('target'));
    } else {
      target = $('#preview');
      $('#preview:hidden').css({
        'top':$(document).scrollTop() + 200,
        'left':$(document).scrollLeft() + 100,
      }).show('fast');
      $('#preview').draggable();
    }
    
    $.ajax({
      url:url,
      success:function(resp) {
        
        target.find('.content').html(resp).css('top',0);
        target.update(url);
      }
    })
  
    
    return false;
  })
}

function inlineForms(scope) {
  $(scope).children('form[class=inline]').ajaxForm(function(response){
    scope.html(response);
    inlineFacts(scope)
  });
}

function inlineFacts(scope) {
  $("span.step-options a").click(
    function() {
      var step = $(this).parents(".step");
      $.ajax({
        url:$(this).attr('href'),
        dataType:'html',
        cache:false,
        success:function(response) {
          step.html(response);
          inlineForms(step);
        }
      })
  
      
      // $('#popup').show();
      return false;
    }
  );
}
   
  function setEditMode() {
    $('.browse-lnk').live('click', function(ev) {
      $('body').removeClass('edit-mode');
      $('.box').draggable('destroy').resizable('destroy');
      
      $(this).parent().hide('fast');
      $('.edit-lnk').parent().show('fast');
      return false;
    });
    $('.edit-lnk').live('click',function(ev){
        $('.section').resizable();
        // $('.box').draggable({
        //    stop:function() {
        //     $(this).saveCoordinates();
        //    }
        //  }).resizable({
        //    stop:function() {
        //      $(this).saveCoordinates();
        //    }      
        //  });
      $('body').addClass('edit-mode');
      $('#nuniverse').draggable('destroy');
      $(this).parent().hide('fast');
      $('.browse-lnk').parent().show('fast');
      return false;
    });

    $('.save-button').click(function(ev) {
      $('body').removeClass('edit-mode');

      $('.box').resizable('destroy').draggable('destroy');
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
      var data = "<layout>"
      $("#nuniverse .box").each(function(i) {
        var title = $(this).find('textarea.title').val();
        var tags = $(this).find('input.tags').val();
        $(this).find('h2').html(title);

        data += "<box><title>"+title+"</title><tags>"+tags+"</tags><content></content><dimension><x>"+$(this).position().left+"</x><y>"+$(this).position().top+"</y><width>"+$(this).width()+"</width><height>"+$(this).height()+"</height></dimension></box>"
      });
      data += "</layout>"


      $.ajax({
        url:'/save-layout.xml',
        // contentType:'text/xml',
        type:"POST",

        data:{xml:data},
        success:function(resp) {

        }
      })
        return false;

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
    // $(".close-btn").live("click", function(ev) {
    //        $(this).parent().hide();
    //        
    //        return false;
    //      }
    //    );
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
            source.find('img').replaceWith($(resp))
            box.hide();
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
   $.serialScroll({target:'.section',duration:500, 'axis':'x', lazy:true})
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
    
   var it;
   // $('#nuniverse').draggable({
   //         start:function(){
   //           $('#nuniverse').data('top', $('#nuniverse').offset().top),
   //           $('#nuniverse').data('left', $('#nuniverse').offset().left)
   //          },
   //          
   //          drag:function() {
   //                $('#nuniverse').data('top', $('#nuniverse').offset().top),
   //                $('#nuniverse').data('left', $('#nuniverse').offset().left)
   //          },
   //    
   //          stop:function() {
   //            
   //            var transX = $('#nuniverse').data('left') - $('#nuniverse').offset().left;
   //            var transY = $('#nuniverse').data('top') - $('#nuniverse').offset().top;
   //            var speedX = Math.min(Math.abs(transX),20);
   //            var speedY = Math.min(Math.abs(transY),20);
   //            var modX = (transX < 0) ? -1 : 1; 
   //            var modY = (transY < 0) ? -1 : 1;
   //            clearInterval(it);
   //            
   //            it = setInterval(function() {
   //              
   //              speedX -= 1;
   //              speedY -= 1;
   //              if(speedX >= 1) {
   //                $('#nuniverse').css('left',$('#nuniverse').offset().left-(speedX * modX));
   //              }
   //              
   //              if(speedY >= 1) {
   //                $('#nuniverse').css('top',$('#nuniverse').offset().top-(speedY * modY));
   //              }
   //              
   //              
   //              if(speedX <= 0 && speedY <= 0) {
   //                clearInterval(it);
   //              }
   //            }, 30)
   //          }
   //      });
     
     $('.tile').hover(function(ev) {
       $(this).addClass("tile-hover");
     }, function(ev) {
       $(this).removeClass("tile-hover");
     }).click(function(ev) {
       $(this).view();

       
       // $('#nuniverse').scrollTo($(this),{axis:'xy', duration:600, offset:-300, queue:true})
     });
   }
   
   
   
   function createBox(parent,coordinates) {
     var box = $('<div class="box"><div class="wrap" style="padding:0 10px 0 0;height:100%"><textarea value="" style="background:none;width:100%;height:100%;padding:0;border:none"/></div></div>').appendTo(parent);
     var hex = Math.floor(Math.random()*255*255*255).toString(16);
     while (hex.length<6) hex = "0" + hex;
                     
      box.css({
        'position':'absolute',
        'width':'100px',
        'height':'25px',
        'background':'#'+hex,
        'top':coordinates.y,
        'left':coordinates.x,
        'overflow':'hidden'
      }).draggable().resizable();
      
      box.mouseenter(function(ev) {
         ev.stopPropagation();
       });

       box.mouseleave(function(ev) {
         ev.stopPropagation();
         box.resizable('destroy');
         box.find('textarea').blur();
         
       });
       
       box.mousedown(function(ev) {
         ev.stopPropagation();
         box.data('evx', ev.pageX);
         box.data('evy',ev.pageY)
       })
       
    
       
       box.dblclick(function(ev) {
         ev.stopPropagation();
         if(box.data('evx') == ev.pageX && box.data('evy') == ev.pageY) {
           box.resizable();
         }
         return false;
       })
      return box;
   }
   
   function setDrawables() {
     $(document).mouseup(function(ev) {
        $(document).unbind('mousemove');
        $('#nuniverse').data('last_box').find('textarea').focus();
      })
          
     $(document).mousedown(function(ev){
       
       var box = createBox($('#nuniverse'),{x:ev.pageX,y:ev.pageY});
       $('#nuniverse').data('last_box', box)
       
       $(document).mousemove(function(ev) {
         box.css({
           width:ev.pageX - box.offset().left,
           height:ev.pageY - box.offset().top,
         });
       });
       
   
     });
    
   }
   
  
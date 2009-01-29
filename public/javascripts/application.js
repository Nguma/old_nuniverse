
// var windowScroll;
// var inputBox;
var previewBox;
var filterBox;
var searchBox;
// 
// function getPreviousConnectionWithSmallerScoreThan(score, el) { 
//   var c = null
// 
//   el.getAllPrevious('.connection').each(function(co) {
//     var sc = Number(co.getElement('.score').get('text'));
//    
//     if(sc < score) {  c = co; return c; }
//     
//   });
//   return c;
// }

$(document).ready(function()
{
  
  
  $.localScroll({axis:'xy', duration:800, margin:true, queue:true, offset:{left:-60,top:-80}, lazy:true});
  setExpandLinks($(document));
  
  setConnections($(this));
  
  $('a.preview-lnk').click(
    function() {
       $('#popup .content').load($(this).attr('href'));
       $('#popup').css('top',$(this).offset().top+20).css('left', $(this).offset().left).show();
       return false;
    }
  );
  
  $('.new-story-lnk').click(
    function() {
      $('#new-story-popup').css('top', 00).css('left',200)
      $("#new-story-popup").show();
      return false;
    }
  );
  
  
  inlineFacts(window);
  
  $(this).setForms();
  

  
 
  

  $('#input-visit').makeSuggestable();
  
  $(".close-btn").click(
    function(ev) {
      $(this).parent().hide();
      return false;
    }
  );
  
  $('#notice').hide();
  
  $('.popup').draggable();

  
  $('.search-input').keyup(function(ev) {
    var target = $(this).parents('.section').children('.content');
    $.ajax({
      url:$(this).parents('form').attr('action')+'?input='+$(this).val(),
       success:function(response) {
         target.html(response)
         setPaginationLinks(target)
         
        }
    })
  })
  
  
  $('#tab-menu a').click(function(ev) {
    selectTab($(this));
  });
  
  selectTab($('#tab-menu a[id!=logout]:first'));
  
  $('#box-button').click(function(ev){
    
    var box = $('#box-template').clone().appendTo($('#nuniverse'));
    box.attr('id', "")
    box.show('fast').draggable().resizable({autoHide:true});
    return false;
  });
  
  $('#image-button').click(function(ev) {  
    var box = $('#image-box-template').clone().appendTo($('#nuniverse'));
    box.attr('id', "")
    box.show('fast').draggable().resizable({autoHide:true});
   
    
    
    return false;
  });
  
  
  $('#connect_image_form').ajaxForm(

    {
      iframe:true,
      success:function(resp, form) {
        var source = $('#'+$(form).find('#type').val()+'_'+$(form).find('#id').val());
        var box = $(form).parents('.box');
        source.find('img').html(resp)
        box.empty();
        // box.html(resp)
        
      }
    });


  
  $('.edit-button').click(function(ev){
    $('.box').resizable().draggable();
    $('body').addClass('edit-mode');
    $('#nuniverse').draggable('destroy')
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
        var destX = 20
        var it = setInterval(function() {
          destX -= 1;
          $('#nuniverse').css({
            'left':$('#nuniverse').offset().left+destX
          });
          if(destX == 0) {
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
  
  $('.box').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  }).dblclick(function(ev) {
    ev.stopPropagation();    
  });

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
  
   var it;
   $('#nuniverse').draggable({
      start:function(){
        $('#nuniverse').data('top', $('#nuniverse').offset().top),
        $('#nuniverse').data('left', $('#nuniverse').offset().left)
       },
       
       drag:function() {
             $('#nuniverse').data('top', $('#nuniverse').offset().top),
             $('#nuniverse').data('left', $('#nuniverse').offset().left)
       },

       stop:function() {
         
         var transX = $('#nuniverse').data('left') - $('#nuniverse').offset().left;
         var transY = $('#nuniverse').data('top') - $('#nuniverse').offset().top;
         var destX = Math.min(Math.abs(transX),20);
         var destY = Math.min(Math.abs(transY),20);
         var modX = (transX < 0) ? -1 : 1; 
         var modY = (transY < 0) ? -1 : 1;
         clearInterval(it);
         
         it = setInterval(function() {
           
           destX -= 1;
           destY -= 1;
           if(destX >= 1) {
             $('#nuniverse').css('left',$('#nuniverse').offset().left-(destX * modX));
           }
           
           if(destY >= 1) {
             $('#nuniverse').css('top',$('#nuniverse').offset().top-(destY * modY));
           }
           
           
           if(destX <= 0 && destY <= 0) {
             clearInterval(it);
           }
         }, 30)
       }
   });
   
   $('#nuniverse .section').each(function(i) {
      // scale($(this));

    })
    
    $('a.destroy-box-lnk').click(function(ev){
      $(this).parents('.box').remove();
      return false;
    });
    
 
    
    $('.step img.default_img').click(function(ev) {
      var popup  = $('#preview').show('fast')
      var connection = $(this).parent();
      popup.find('.content').html($(this).parent().clone().css({'left':0,'top':0,'position':'relative'}))
      popup.append($('.image-form-box form').clone(true));

      ev.stopPropagation();
      
      popup.find('input#source_id').val(connection.find('#id').val())
      popup.find('input#source_type').val(connection.find('#type').val());
    //     return false;
    })
    
    
    $('#preview').draggable().resizable();

   
});


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






  // Ajaxifies each .connections present in the scope
  function setConnections(scope) {
    if(scope.hasClass('connection')) {
      connections = scope
    } else {
      connections = scope.find('.connection')
    }
    
    scope.find('.options a').hover(function(){
     
    }, function() {
  
    }).click(function(ev) {
      var con = $(this).parents('.connection');
      ev.stopPropagation();

      return false;
    });
    
     connections.hover(
                function() {
                $(this).addClass('hover'); 
              }, 
                function() {
                $(this).removeClass('hover');
                $('#contextual-content').hide();
              })
      connections.find('a').click(function(ev) {
                  ev.stopPropagation();
                  clickConnection($(this));
                  return false;
                });
        
          
    
  }


function clickConnection(connection) {
  goToNewSection(connection); 
  return false;
}

function goToNewSection(connection) {
    var new_section = $('#section-template').clone().attr('id', connection.attr('title'));
     var current_section = connection.parents('.section');
     var current_lnk = $('#tab-menu li:has(a[href=#'+current_section.attr('id')+'])');
     // new_section.find('.hat').html(connection.find('.body').clone().html());
     current_section.nextAll().remove();
     current_lnk.nextAll().remove(); 
     current_section.after(new_section);
     new_section.css('top',$(document).scrollTop()).show('fast');
     // scale(new_section)
     
     $.ajax({
       url:connection.attr('href'),
       success:function(resp) {
         new_section.find('.content').html(resp);
         update(new_section);
         
       }
     });
     
     $('#tab-menu').append(connection.clone());
     $('#tab-menu a:last').wrap("<li></li>").attr('href','#'+new_section.attr('id'));
     
     $('#tab-menu a:last').click(function(ev){
        selectTab($(this)); 
     }).trigger('click');
     $('html,body').animate({"scrollLeft":new_section.position().left - 100}, 500);
}



  // Update: Called after each Ajax update, to refresh updated section
  function update(section) {
    section.find('.menu a').click(function(ev) {
     
      $.ajax({url:$(this).attr('href')})
      return false;
    });
    setPagination(section);
    setConnections(section);
    section.setForms();
    
    setExpandLinks(section);
    setSubMenu(section);
    section.resizable({
      handles:{
        e:'.border-e',
        s:'.border-s'
      }
    });

  }
  
  // Creates and connect submenu items
  function setSubMenu(section) {
    
    section.find('.sub-menu').clone(true).prependTo($('#sub-menu'));
    
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
    var section = $(lnk.attr('href'));
    $('#tab-menu .selected').animate({"left":li.position().left, "width":li.width()}, "slow");
    $('#sub-menu').empty();
    section.find('.sub-menu').clone(true).prependTo($('#sub-menu'));
    $('#nuniverse').data('section', section)

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


jQuery.fn.extend({
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
              suggestions.find('.suggestion').click(function(ev) {
                
                 eval(callback($(this)))
                 return false;
              });
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
    $(this).find('form').ajaxForm(function(resp) {
       scope.hide();
       $($('#nuniverse').data('section')).children('.content').append(resp);
    });
  },
  
  // Checks for live content
  // passes a url for calls
  update:function(url) {
    $(this).setForms();
    $(this).createSuggestables(url);
  },
  
  // previews the item in the preview box
  // bool = Clone effects or not
  preview:function(bool) {
    var preview = $('#preview');
    preview.find('.content').html($(this).clone(bool).css({'left':'0','top':'0px'}));
    
    $.ajax({
      url:$(this).attr('href'),
      success:function(resp) {
        preview.find('.content').html(resp);
      }
    })
    $('#preview:hidden').css({'left':$(this).offset().left, 'top':$(this).offset().top}).show('fast');
  }
  
  
});

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
  

function setExpandLinks(scope) {
  scope.find('a.expand-lnk').click(function(ev) {
    
    var popup = $('#preview')

    var url = $(this).attr('href');
    $.ajax({
      url:url,
      success:function(resp) {
        popup.find('.content').html(resp);
        popup.update(url);
      }
    })
  
    $('#preview:hidden').css({
         'top':$(document).scrollTop() + 200,
         'left':$(document).scrollLeft() + 100,
         }).show('fast');
    return false;
  })
}

function inlineForms(scope) {
  $(scope).children('form').ajaxForm(function(response){
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
 
 function uploadJS() {
   console.log("UPLOADED")
 }
 



  
  $(window).unload(function() {
    
  });


  
  jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  });
  
  $(document).ajaxSend(function(event, request, settings) {
    if (typeof(AUTH_TOKEN) == "undefined") return;
    // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
    settings.data = settings.data || "";
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
  });
  
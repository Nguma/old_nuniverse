$(window).unload(function() {
  
});

$(document).ready(function()
{  
  setLocalScroll();
  setCloseButtons(); 
  setTabs();
  setImagesActions();
  setStars();
  setScore();
  setInputCommand();
  setSearchInput();
  setConnections();
  setGeneral();
  setTagLinks();
  

});

  function setTagLinks() {
    $('.tag-lnk').live('click', function(ev) {
      ev.preventDefault();
      $('#tags').find('.selected').removeClass('selected');
      $(this).addClass('selected');
   
      var taste = $('#tastebook').find('dd:first').clone();
      $('#tastebook').empty();
      $.getJSON($(this).attr('href')+'.json', function(json) {
        $.each(json.tastebook, function(i) {
          makeNewTaste(this);
        });
      });
    });
  }


  function setTabs() {
    $('#breadcrumbs a').live("click",function(ev) {
      ev.stopPropagation();
      ev.preventDefault();
      selectTab($(this));
    });
  
    $('.tabs a').live('click',function(ev) {
      ev.preventDefault();
      var target = $($(this).parents('.tabs').attr('target'));
      target.children('dd').hide();
      $($(this).attr('target')).fadeIn('slow');
      activateTab($(this));
    });
  
  }
  
  function activateTab(tab) {
    var tabs = tab.parents('.tabs');
    var selected = tabs.find('.selected');
    selected.removeClass('selected');
    tab.parent().addClass('selected');
    $(selected.find('a').attr('target')).hide();
    $(tab.attr('target')).fadeIn('fast');
    eval('onSelect'+tab.attr('href'))();
  }


  function onSelectTasteBook() {
    $('#tastemakers').hide();
    $('#tags').fadeIn('fast');
  }
  
  function onSelectConnections() {
    
  }
  
  function onSelectBookmarks() {
    
  }
  
  function onSelectJustTasted() {
    $('#tastemakers').show();
    $('#tags').hide();
  }

  function onSelectPros() {
    $('#stats').hide();
  }
  
  function onSelectCons() {
    $('#cons').show();
    $('#stats').hide();
  }
  
  
  function onSelectExperienced() {
    $('#stats').fadeIn('fast')
  }



  // Update: Called after each Ajax update, to refresh updated section
  function update(section) {
    section.height($(window).height()).css('top',0);
    section.movable({target:'.content'});
    section.find('.menu a').click(function(ev) {
      $.ajax({url:$(this).attr('href')})
      return false;
    });
    
 
    section.setForms();
    setSubMenu(section);
  }


  var suggest_request = null 
  function suggest(el) {
    if(suggest_request) { suggest_request.abort();}
    $('#connections').empty();
    suggest_request = $.getJSON("/search-for/"+el.val()+".json", function(json) {
    
      $.each(json.results, function(i) {
        var result = $('#templates').find('.result').clone();
        if(this.image == undefined) {
          result.find('.thumbnail').hide();
        } else {
          result.find('.thumbnail').attr('src', this.image);
        }
       
        result.find('.name').html(this.name).attr('href',this.url);
      
        result.find('.tags').html(this.tags);
        result.appendTo($('#connections'));
      });
    

    
    });
  
  }


  function setPaginationLinks(scope) {
     $('.pagination a').click(function(ev) {
            ev.preventDefault();
            $.ajax({
              url:$(this).attr('href'),
              target:scope
            });
            return false;
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
  
  
  function updateScoreCard(json) {
    $('#score').removeClass();
    $('#score').addClass('score_'+Math.round(json.score)).html(json.score).hide().fadeIn('slow');
    
    var vote = $('#vote-by-'+json.user);
    vote.css({
      'background':json.color
    });
    
    vote.find('.score').html(json.vote.score).hide().fadeIn('fast');
    
    $.each(json.stats,function(i,stat) {
      $('#stat_'+stat.score).animate({width:stat.percent});
      $('#stat_'+stat.score).find('.percent').html(stat.percent+'%')
    });
    $('#score-label').removeClass().css({'color':json.color}).html(json.score_label);
    $('#scorecard .status').html('Your rate: <span class="score_'+ json.vote.score +'">'+ json.vote.score +'</span>').show();
    // $('#scorecard').addClass('voted');
    $('#change-your-mind-lnk').show();
    // $('#rate-picker').hide();
  }
  
  function expandInput(order, href) {
    if (href != undefined) {
      $('#input_form').attr('action', href);
    }
    $('#input_form').fadeIn('fast');
    $('#input_order').attr('size',order.length+3).val(order);
    $('#input_value').focus();
  }
  
  
  function makeNewTaste(json) {
    var new_taste = $('#templates').find('.taste').clone();
    new_taste.find('h2 a').html(json.name).attr('href', json.wdyto_uri)
    new_taste.find('.thumbnail').attr('src', json.image);
    new_taste.find('.actions').css('background', $('#stat_'+Math.round(json.score)).css('background'));
    new_taste.find('.tags').html(json.tags);
    new_taste.find('.score').html(json.score);
    new_taste.appendTo($('#tastebook')).hide().fadeIn('slow');
  }
  
  function saveToTasteBook(lnk) {
    $.getJSON(lnk.attr('href')+'.json', function(json) {
      switch(json.action) {
        case "add":
          makeNewTaste(json.element);
        case "remove":
          $('#'+json.element.unique_name).slideUp('fast');
        default:
      }
     
    });
  }
  
  function setStars(){
    $('.star').live('click', function(ev) {
      ev.preventDefault();
      $(this).toggleClass('saved');
      saveToTasteBook($(this));
    });
  }
  
  function setScore() {
    
    // $('#scorecard').appendTo($('#highlight_score'))
    $('#change-your-mind-lnk').live('click', function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      $($(this).attr('target')).toggle();
      $(this).hide();
      $('#scorecard').find('.status').hide();
      $('#rate-picker').show();
     
    });

    $('.rate-lnk').live('click', function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      $('#rate-picker').hide();
      $('#change-your-mind-lnk').show('fast');
      $.getJSON($(this).attr('href')+'.json',function(json) {
        updateScoreCard(json);
      });
      expandInput('Review',"/comments/create");

    });
  }
  
  
  function setInputCommand() {
    $('.input-lnk').live('click', function(ev) {
      ev.preventDefault();
      expandInput($(this).attr('target'),$(this).attr('href'));
    });

    $('#input_order').keyup(function(ev) {
      $(this).attr('size', $(this).val().length*1.5);
    });

    $(document).keypress(function(ev) {
             if(isValidKey(ev) && !ev.ctrlKey && !ev.shiftKey && !ev.metaKey && !ev.altKey) {
               $('#input_form:hidden').each(function() {
                 $(this).fadeIn('fast');
                 if(ev.which != 32) {
                   // var path = $('#nuniverse').data('current_section').find('.category').text();
                   // $('#input_value').val(path+ String.fromCharCode(ev.which)).focus();
                 } else {
                   $('#input_value').focus();
                 }
        
               });
             }
           });

    $('#input_form').submit(function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      // var section = $('#nuniverse').data('current_section');

      // $(this).find('.source-id').val(section.find('.source-id').val());
      // $(this).find('.source-type').val(section.find('.source-type').val());
      // $(this).find('#input_path').val(section.find('.path').text());

      var url = ("/"+$('#input_order').val().toLowerCase()+"/"+$('#input_value').val()+'/').replace(/\s/g,'_')

       $(this).ajaxSubmit({

          resetForm:true,
          success:function(resp) {

            $(resp).find('.comment' ).prependTo($('#comments')).hide().slideDown('fast');
            $(resp).find('.connection').prependTo($('#connections')).hide().slideDown('fast');   


          }
        });
      return false;
    });

    var ajax_timeout;
    $('#input_value').keypress(function(ev) {
      if (ajax_timeout != undefined) {clearTimeout(ajax_timeout)};
      var el = $(this);
      var delay = 300;


      if(ev.which == 13 ) {
        ev.preventDefault();

        $(this).parents('form').submit();

      } else if (ev.keyCode == 27) {
        $(this).parents('form').fadeOut('fast');
      } else if(isValidKey(ev) && !ev.ctrlKey && !ev.shiftKey && !ev.metaKey && !ev.altKey) {

        ajax_timeout = setTimeout(function() {
          suggest(el);
        }, delay);
      }
    });
    
  }
  
   var ajax_timeout;
  function setSearchInput() {
    $('#search-input').keypress(function(ev) {
      if (ajax_timeout != undefined) {clearTimeout(ajax_timeout)};
      var el = $(this);
      var delay = 300;


      if(ev.which == 13 ) {
        ev.preventDefault();

        $(this).parents('form').submit();

      } else if (ev.keyCode == 27) {
        $(this).parents('form').fadeOut('fast');
      } else if(isValidKey(ev) && !ev.ctrlKey && !ev.shiftKey && !ev.metaKey && !ev.altKey) {

        ajax_timeout = setTimeout(function() {
          suggest(el);
        }, delay);
      }
    })
    
  }
  
  
  function setConnections() {
    $('.connection').hover(function(ev) {
       $(this).addClass('hover');
     }, function(ev) {
       $(this).removeClass('hover');
     });


     $('.connections a.expand-lnk').live('click', function(ev) {

       $(this).parents('dl').find('.activated').removeClass('activated');
       $(this).parent('dd').addClass('activated');
       $('#left-col').animate({width:'19%'}, 'slow');
         $('#center-col').animate({width:'31%'}, 'fast');
         $('#right-col').animate({width:'40.6%'}, 'slow');
        ev.preventDefault();
        $.ajax({
          url:$(this).attr('href'),
          success:function(resp) {
            expandSection(resp);
          }
        })
      });
  }
  
  function setFactBox() {
    
    var items = $('#facts').find('.fact');
    var i = 0
    // $('#facts').serialScroll({target:'dl',axis:'y', interval:100});

    var fact_timeout = setInterval(function(ev) {
      i += 1;
     $('#facts').scrollTo(items[i], 'slow');

    }, 5000);
  }
  
  
  function setGeneral(){
    $('.toggle-lnk').live('click', function(ev) {
      ev.preventDefault();
      $($(this).attr('target')).toggle();
    });

    $('#media a.expand-lnk').live('click', function(ev) {
      ev.preventDefault();
    });

    $('#input-visit').makeSuggestable();
    $('#notice').hide();
    $('.popup').draggable();
    $('#message').hover(function(ev) {
      $(this).stop(true).show();
    }, function(ev) {
      $(this).fadeOut();
    })


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
  }
  
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
          suggest();
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
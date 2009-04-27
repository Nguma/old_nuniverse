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
  
  setGeneral();
  setTagLinks();
  setTagFields();
  rotateHomeFeed();
  
  setPaginationLinks();
  
  $('#input_uploaded_data').change(function(ev) {
    ev.preventDefault();
    submitInputForm();
    return false;
  })
  
  $('#login-form input').blur(function(e) { $(this).showLabelIfEmpty(); }).focus(function(e) {$(this).updateOnFocus();});

 
  $('#signup_login').keypress(function(e) {
    var timeout = $('#signup_form').data('timeout'); 
    var code = (e.keyCode ? e.keyCode : e.which);
    if(code == 9) return;
    if(String.fromCharCode(code).match(/[a-zA-Z0-9_]/) || code == 8) { 
      if ( timeout != undefined) {clearTimeout(timeout)};
      $('#signup_form').data('timeout', setTimeout(function() {validate('login');},300));
    } else {
      e.preventDefault();
    }
  });
  
  $('#signup_password').keyup(function(e) {
      var code = (e.keyCode ? e.keyCode : e.which);
      if(code == 9) return;
      var signal =  $(this).siblings('.signal');
      if($(this).val().length >= 4) {
        signal.hide().css({background:'#0F0'}).fadeIn('fast').html('ok');
      } else {
        signal.hide().css({background:'#F00'}).fadeIn('fast').html('too short!');
      }
      validateSignupForm();
  });
  
  $('#signup_email').keypress(function(e) {
    var timeout = $('#signup_form').data('timeout');
    var code = (e.keyCode ? e.keyCode : e.which);
    if(code == 9) return;
    if(String.fromCharCode(code).match(/[a-zA-Z0-9_\.\-\@]/) || code == 8 || code == 45 || code == 46 || code == 43 || code == 95 ) {
      
      if ( timeout != undefined) {clearTimeout(timeout)};
      $('#signup_form').data('timeout', setTimeout(function() {validate('email');},300));
    } else {
      e.preventDefault();
    }
  });
  
  
  $('.input_suggestion a').live('click', function(ev) {
    ev.preventDefault();

    acceptSuggestion($(this))
  });
     
});

  function setTagLinks() {
    
    $('.tag').hover(function() {$(this).addClass('hover')}, function() {$(this).removeClass('hover')});
    
    $('.remove-tag-lnk').click(function(ev) {ev.preventDefault(); $(this).parent().remove(); $.getJSON($(this).attr('href'))});
    $('.tag-lnk').live('click', function(ev) {
      ev.preventDefault();
      $('#tags').find('.selected').removeClass('selected');
      $(this).addClass('selected');
   
      var taste = $('#tastebook').find('dd:first').clone();
      $('#tastebook').empty();
      $.ajax({
        'url':'/users/tastebook?filter='+$(this).html()+'&namespace=nguma',
        success:function(resp) {$('#tastebook').html(resp);}
        
      });
      // $.getJSON($(this).attr('href')+'.json', function(json) {
      //         $.each(json.tastebook, function(i) {
      //           makeNewTaste(this);
      //         });
      //       });
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
      activateSection($($(this).attr('target')));
    });
    
    $('a.section-lnk').live('click', function(e) {
      e.preventDefault();
      activateSection($($(this).attr('target')));
    });
  
  }
  
  function activateSection(section) {
    $('#hat').hide();
    section.siblings().hide();
    section.fadeIn('fast');
    setSelected($("#tab-"+section.attr('id')));
    eval('onSelect'+section.attr('id').capitalize())();
  }
  
  
  
  function setSelected(el) {
    var selector = el.parent();
    selector.children('.selected').removeClass('selected');
    el.addClass('selected');
  }
  
 
 function onSelectReviews() {
   
 }
 
 function onSelectOverview() {
   $('#hat').stop().show();
 }
 
  function onSelectComments() {
    
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
    $('#feeds').hide();
    $('#suggestions').empty().show();
    suggest_request = $.getJSON("/search-for/"+el.val()+".json", function(json) {
    
      $.each(json.results, function(i) {
        var result = $('#templates').find('.suggestion').clone();
        if(this.image == undefined) {
          result.find('.thumbnail').hide();
        } else {
          result.find('.thumbnail').attr('src', this.image);
        }
       
        result.find('.name').html(this.name).attr('href',this.url);
      
        result.find('.tags').html(this.tags);
        result.appendTo($('#suggestions'));
      });
    

    
    });
  
  }


  function setPaginationLinks() {
    $('.pagination a').live('click', function(e) {
      e.preventDefault();
      var dl = $(this).parents('dl:first');
      
      dl.empty();    
      $.ajax({
        url:$(this).attr('href'), 
        success:function (resp) { 
          dl.html(resp); 
        }
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
  
  
  function isValidKey (ev) {
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
    // $('#score-label').removeClass().css({'color':json.color}).html(json.score_label);
     // $('#scorecard .status').html('Your rate: <span class="score_'+ json.vote.score +'">'+ json.vote.score +'</span>').show();
    // $('#scorecard').addClass('voted');
    // $('#change-your-mind-lnk').show();
    // $('#rate-picker').hide();
  }
  
  function expandTagger(params) {
    $('#tagger').hide();
    $('#tagger_input').val(params['val']);
    $('#tagger').appendTo(params['target']).show();
    // css({top:params['x'], left:params['y']}).fadeIn('fast');
  }
  
  function setTagFields() {
    $('.connection .tags a').click(function(ev) {
      ev.preventDefault();
      var val = $(this).html();
      $(this).hide();
      expandTagger({val:val, target:$(this).parent()})
    });
  }
  
  
  
  function expandInput(params) {
    if (params['href'] != undefined) {
      $('#input_form').attr('action', params['href']);
    }
    
    if(params['kind'] != "image") {
      $('#input_uploaded_data').hide();
      $('#upload_button').hide();
    } else {
       $('#input_uploaded_data').show();
       $('#upload_button').show();
    }
    
    $('#input_form .label').html(params['title']);
    $('#input_form').fadeIn('fast');
    $('#input_order').attr('size',params['rel'].length+3).val(params['rel']);
    $('#input_form').data('target', params['target']);
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
    $('.stars a').live('click', function(ev) {
      ev.preventDefault();
      $(this).parent('.stars').toggleClass('saved');
      saveToTasteBook($(this));
    });
    
    $('.tippable').mouseenter(function(ev) {
      $('#tooltip').css({'top':ev.pageY, 'left':ev.pageX})
      $('#tooltip .title').html($(this).attr('title'));
      $('#tooltip').stop().hide().show('fast');
    });
    $('.tippable').mouseleave(function(ev) {
       $('#tooltip').stop().hide('fast');
    });
    
  }
  
  function setScore() {
    
    // $('#scorecard').appendTo($('#highlight_score'))
    $('#change-your-mind-lnk').live('click', function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      $($(this).attr('target')).toggle();
      $(this).hide();
      $('#stats').hide();
      $('#scoretag').hide();
      $('#rate-picker').show();
    });

    $('.rate-lnk').live('click', function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      $('#rate-picker').hide();
      $('#vote').hide();
      $('#stats').fadeIn('fast');
      $('#scoretag').fadeIn('slow');
      $('#change-your-mind-lnk').show();
      $.getJSON($(this).attr('href')+'.json',function(json) {
        updateScoreCard(json);
      });
      
      expandInput({
        'title':"You're giving a "+$(this).html()+" because",
        'kind':'Rating',
        'rel':'Review',
        'href':"http://localhost:3000/comments/create.js"
      });

    });
  }
  
  
  function setInputCommand() {
    $('.input-lnk').live('click', function(ev) {
      ev.preventDefault();
      
      expandInput({
        rel:$(this).attr('rel'),
        kind:$(this).attr('name'),
        target:$(this).attr('target'),
        href:$(this).attr('href'),
        title:$(this).attr('title')
      });
    });

    $('#input_order').keyup(function(ev) {
      $(this).attr('size', $(this).val().length*1.5);
    });
    // 
    // $(document).keypress(function(ev) {
    //          if(isValidKey(ev) && !ev.ctrlKey && !ev.shiftKey && !ev.metaKey && !ev.altKey) {
    //            $('#input_form:hidden').each(function() {
    //              $(this).fadeIn('fast');
    //              if(ev.which != 32) {
    //                // var path = $('#nuniverse').data('current_section').find('.category').text();
    //                // $('#input_value').val(path+ String.fromCharCode(ev.which)).focus();
    //              } else {
    //                $('#input_value').focus();
    //              }
    //     
    //            });
    //          }
    //        });

    $('#input_form').submit(function(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      submitInputForm();
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
 
        if ($('#input_order').val() == "connect" && $('#input_value').val().match(/\#\w+$/) ) {
          
          ajax_timeout = setTimeout(function() {
            $('#input_form').ajaxSubmit({
              url:"/suggest-connection",
              success:function(resp) {
                $('#input-suggestions').html(resp)
              }
            });
          }, delay);
        }
        
        
      }
    });
    
  }
  
  
  var ajax_timeout;
  function setSearchInput() {
    
    $('#search-lnk').click(function(ev) {
      ev.preventDefault();
      $('#search-form').toggle('fast');
    });
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
  
  

  
  function setFactBox() {
    
    var items = $('#facts').find('.fact');
    var i = 0
    // $('#facts').serialScroll({target:'dl',axis:'y', interval:100});

    var fact_timeout = setInterval(function(ev) {
      i += 1;
     $('#facts').scrollTo(items[i], 'slow');

    }, 5000);
  }
  
  function submitInputForm() {
     var target = $('#input_form').data('target');
     var iframe = (target == "media" || target == "bad-face") ? true : false
   
     $('#input_form').ajaxSubmit({
        iframe:iframe,
        resetForm:true,
        success:function(resp) {
          if (target != undefined && target != "") {$('#'+target).html(resp).hide().slideDown('fast');}
          $(resp).find('.comment').prependTo($('#reviews')).hide().slideDown('fast');
          $(resp).find('.connection').prependTo($('#connections')).hide().slideDown('fast');
          $(resp).find('.fact').prependTo($('#facts')).hide().slideDown('fast');
          $(resp).find('.tag').prependTo($('#tags'));
          $(resp).find('.image').prependTo($('#media')).hide().slideDown('fast');
          $('#input_form').fadeOut('slow');
        }
      });
      // var url = ("/"+$('#input_order').val().toLowerCase()+"/"+$('#input_value').val()+'/').replace(/\s/g,'_');
      return false;
  }
  
  function setGeneral(){
    $('.toggle-lnk').live('click', function(ev) {
      ev.preventDefault();
      $($(this).attr('target')).toggle();
    });

    $('#media a.expand-lnk').live('click', function(ev) {
      ev.preventDefault();
    });

    // $('#input-visit').makeSuggestable();
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
    
    // Replaces empty field with the previous label value, and adds the 'empty' class to the field in a positive case 
    showLabelIfEmpty:function() {
      if($(this).val() == "") {
        $(this).val($(this).prev('label').html());
        $(this).addClass('empty');
        
      } 
    },
    
    // Reset field if with 'empty' class, and removes that class
    updateOnFocus:function() {
       if($(this).hasClass('empty')) {
          $(this).removeClass('empty').val("");
        };
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
  
  
  function validateSignupForm() {
    var ok = true;
    $('#signup_form .signal').each(function(i) {
     if($(this).html() != 'ok') { ok = false;}
    
    });
    if(ok == true) {
      $('#signup_submit').show();
    } else {
      $('#signup_submit').hide();
    }
    
    return true;
  }
  
  function rotateHomeFeed() {
    var hf = $('#homepage_feed');
    hf.data('index', 0);
    if(hf.length == 1) {
      hf.data('interval', setInterval(function(ev) {
        hf.data('index', hf.data('index')+1);
        var dd = hf.find('dd')[hf.data('index')];
        hf.scrollTo(dd, 500);
      }, 3000));
    }

  }
  
  function validate(what) {
    var val = $('#signup_'+what).val();
    var signal =  $('#signup_'+what).siblings('.signal');  
    $.getJSON("/validate/"+what+".json", {'value':val}, function(json) {
      if(json.response == 'ok') {
        signal.hide().css({background:'#0F0'}).fadeIn('fast').html(json.response);
      } else {
        signal.hide().css({background:'#F00'}).fadeIn('fast').html(json.response);
      }
    });
    validateSignupForm();  
  }
  
  function acceptSuggestion(suggested_lnk) {
    
    var newval = $('#input_value').val().replace(/\#(\w+)$/,suggested_lnk.attr('title'));
    $('#input_value').val(newval+' ');
    // $('#input_form').fadeOut('fast');
    $('#input-suggestions').empty();
    // $('#input_form').ajaxSubmit({
    //       url:"/make-connection",
    //       success:function(resp) {
    //         $(resp).prependTo($('#connections'));
    //       }
    //     });
  }
  
  Array.prototype.index = function(val) {
    for(var i = 0, l = this.length; i < l; i++) {
      if(this[i] == val) return i;
    }
    return null;
  }

  Array.prototype.include = function(val) {
    return this.index(val) !== null;
  }
  
  String.prototype.capitalize = function(){ //v1.0
      return this.replace(/\w+/g, function(a){
          return a.charAt(0).toUpperCase() + a.substr(1).toLowerCase();
      });
  };
  
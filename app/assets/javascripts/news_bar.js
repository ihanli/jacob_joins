/*function countdown(){
  var days;
  var hours;
  var minutes;
  var seconds;

  var now = new Date();
  now.getTime();
  var time = Date.parse(now);
  
  var release = Date.parse("Su, 03 Jun 2012 00:00:00 GMT+1");
  
  var diff = release - time;
  
  if (diff < 0){
    days = hours = minutes = seconds = "00";
  }
  else {
    var diff = diff /1000;
    
    days = Math.floor( diff/(60*60*24) );
    if(days < 10) days = "0"+days;
    
    hours = Math.floor( (diff - days*24*60*60)/(60*60) );
    if(hours < 10) hours = "0"+hours;
    
    minutes = Math.floor( (diff - days*24*60*60 - hours*60*60)/60);
    if(minutes < 10) minutes = "0"+minutes;
    
    seconds = Math.floor( diff - days*24*60*60 - hours*60*60 - minutes*60);
    if(seconds < 10) seconds = "0"+seconds;
  }

  $('#days').html(days);
  $('#hours').html(hours);
  $('#minutes').html(minutes);
  $('#seconds').html(seconds);
  
  setTimeout('countdown()',200);

};*/


function get_latest_recipe(){
  $.get('/recipes/last', function(data, textstatus, jqxhr) {
    //console.debug(data);
    $.each(data, function(key, value){
      var recipe = value;
      if(recipe && recipe.user_id){
        var id = {"id": recipe.user_id};
        //Get the user, which created the recipe
        $.post('/users/find_user', id, function(data, textstatus, jqxhr){
          var user = data;
          console.debug(user);
          if(user.name && recipe.city)
            $('#last_entry').append("<p>Jacob joins "+user.name+" from "+recipe.city+"</p>");
        }, "json");
      }
    });
  }, "json");
}


function get_facebook_stream(){
  var token = "379307568767425|h4-QpwOXsOJgj36C6ynugq6hQTs";
  $.get('https://graph.facebook.com/111627842294635/feed?access_token='+token, function(data, textstatus, jqxhr){
    var counter = 0;
    $.each(data.data, function(key, value){
      if(value.message && counter <=4){

        /*$.get('https://graph.facebook.com/'+value.from.id+'?fields=picture&type=square', function(data, textstatus, jqxhr){
          $('#newsbar #fb p').append("<img src='"+data.picture+"' alt='profile_picture' />");
          $('#newsbar #fb p').append(value.from.name+":" + "<br />");
          $('#newsbar #fb p').append("Message: "+value.message + "<br />");
          $('#newsbar #fb p').append(prettyDate(value.created_time) + "<br />");
          $('#newsbar #fb p').append("<br />");       
        }, "json");*/
        counter++;
      }
    });
  }, "json");
}

/*
 * JavaScript Pretty Date
 * Copyright (c) 2011 John Resig (ejohn.org)
 * Licensed under the MIT and GPL licenses.
 */
// Takes an ISO time and returns a string representing how
// long ago the date represents.
function prettyDate(time){
  var date = new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," ")),
    diff = (((new Date()).getTime() - date.getTime()) / 1000),
    day_diff = Math.floor(diff / 86400);
      
  if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
    return;
      
  return day_diff == 0 && (
      diff < 60 && "just now" ||
      diff < 120 && "1 minute ago" ||
      diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
      diff < 7200 && "1 hour ago" ||
      diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
    day_diff == 1 && "Yesterday" ||
    day_diff < 7 && day_diff + " days ago" ||
    day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
}

// If jQuery is included in the page, adds a jQuery plugin to handle it as well
if ( typeof jQuery != "undefined" )
  jQuery.fn.prettyDate = function(){
    return this.each(function(){
      var date = prettyDate(this.title);
      if ( date )
        jQuery(this).text( date );
    });
  };


function slide_newsbar(){
  $('#clickandsee').click(function(e){
    return false;
  });
  
  $("#newsbar, .show_newsbar").click(function(e){
    console.log("in");
    var newsBar = $('#newsbar');

    if(newsBar.hasClass('extended')){
      newsBar.stop().animate({
        top: "-215px"
      }, 500);
    } else {
      newsBar.stop().animate({
        top: "0"
      }, 500);
    }

    $("#countdown", newsBar).fadeToggle(500);
    $("#clickandsee", newsBar).fadeToggle(500);

    $('#newsbar').toggleClass('extended');

    return false;
  });
}
function gender_icon(classname){
  $('.female').removeClass('selected');
  $('.male').removeClass('selected');
  $('#user_gender').val(classname);
  $('.'+classname).addClass('selected');
  $('#user_gender').addClass("changed");
  $(".dirtyform", "#user_tab").dirtyValidation("validate", $('#user_gender'), false)
  return false;
}

function heard_from(option){
  if(option == "other")
    $('#heard_from_other').fadeIn('500');
  else 
    $('#heard_from_other').fadeOut('500');
}
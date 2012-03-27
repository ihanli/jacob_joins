var publish_csi = function(user_location) {
  var error = false;

  $.ajax({
    url: "country_specific_informations/draft",
    type: "POST",
    data: {
    	_method: "PUT",
      location:{
        latitude: user_location.latitude,
        longitude: user_location.longitude,
        city: user_location.city,
        country: user_location.country
      }
    },
    success: function(data, textStatus, jqXHR) { error = false; },
    statusCode: {
      400: function(){ error = true; },
      500: function(){ error = true; }
    }
  });

  return !error
};
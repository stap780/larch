$(document).on("ajax:success", function(event, data, status, xhr) {
    //console.log(event);
    //console.log(data);
    //console.log(status);
    $(event.currentTarget).css('disabled');
  }).on("ajax:error", function(event, xhr, status, error){

  });
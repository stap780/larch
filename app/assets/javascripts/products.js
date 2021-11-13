$(document).on("ajax:success", ".delete-image", function(event, data, status, xhr) {
  //var response = data.message;
  //alert('Response is => ' + response);
  if (data.message === 'destroyed') {
    $(this).closest('tr').fadeOut();
  }
});
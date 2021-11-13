// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require cocoon
//= require_tree .



$(document).ready(function() {

  $(".alert").delay(4000).slideUp(200, function() {
    $(this).alert('close');
  });


  // function check_order() {
  //   var order_id = $(".payment_status").data('order-id');
  //
  //   $.ajax({
  //     url: "/orders/status/" + order_id,
  //     dataType: "json",
  //     success: function(data) {
  //       console.log(data)
  //       if (data.status == "PAID") {
  //         $(".payment_status").html('PAID');
  //         window.location = data.redirect_url;
  //       } else {
  //         $(".payment_status").append(' . ');
  //       }
  //     },
  //     error: function(xhr, textStatus, errorThrown) {}
  //   });
  //
  //   setTimeout(check_order, 3000); // 0.5 сек
  // }
  //
  // if ($(".payment_status").length > 0) {
  //   check_order();
  // }

  $('#selectAll').click(function() {
    if (this.checked) {
      $(':checkbox').each(function() {
        this.checked = true;
      });
      $('#deleteAll').show();
    } else {
      $(':checkbox').each(function() {
        this.checked = false;
      });
      $('#deleteAll').hide();
    }
  });

  $('#deleteAll').click(function() {
    // event.preventDefault();
    var array = [];
    $('#items_table :checked').each(function() {
      array.push($(this).val());
    });

    $.ajax({
      type: "POST",
      url: $(this).attr('href') + '.json',
      data: {
        ids: array
      },
      beforeSend: function() {
        return confirm("Вы уверенны?");
      },
      success: function(data, textStatus, jqXHR) {
        if (data.status === 'ok') {
          //alert(data.message);
          location.reload();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    })

  });



});
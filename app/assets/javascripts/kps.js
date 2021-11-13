// калькулятор по позициям и итого
function calculate(val) {
  var table_lines = $('#kp_products tbody tr'); // это нужно чтобы ошибки не выскакивали в js
  if (table_lines.length >= 1) {
    for (var i = 0; i < table_lines.length; i++) {
      var row = table_lines[i];
      //console.log(row);
      var quantity = row.cells[1].firstChild.firstChild.value;
      var price = row.cells[2].firstChild.firstChild.value;
      var sum = quantity * price;
      row.cells[3].firstChild.firstChild.value = sum.toFixed(2);;
    };
    var rows = $("tr.nested-fields:visible");
    var tot = 0;
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i];
      var sum = row.cells[3].firstChild.firstChild;
      if (parseInt(sum.value))
        tot += parseFloat(sum.value);
    }
    // var discount = document.getElementById("invoice_discount");
    // var delivery = $('.delivery').html();
    // if (parseInt(discount.value) > "0") {
    //   var newtot = tot - tot * parseFloat(discount.value) / 100;
    //   document.getElementById('invoice_total_price').value = newtot.toFixed(2);;
    // } else {
    //   document.getElementById('invoice_total_price').value = tot.toFixed(2);;
    // }
    $('#kp-total').html(tot.toFixed(2));
  }
};
//

$(document).ready(function() {

  calculate();

  // пересчет суммы при удалении позиции из перечня товаров в исходящем счете
  $("#kp_products").children('tbody')
    .on('cocoon:before-remove', function(e, task) {
      $(this).data('remove-timeout', 1000);
      task.fadeOut('slow');
    })
    .on('cocoon:after-remove', function(e, removeRow) {
      //console.log($(this));
      // var row = removeRow;
      //console.log(row);

      calculate();
    });



});
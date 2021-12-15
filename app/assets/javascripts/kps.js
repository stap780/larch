//автокомплит init после вставки строки
function initLine() {
  var id;
  var dataId;
  //alert('hi');
  $("#kp_products")
    .on('cocoon:before-insert', function(e, insertedItem) {
      var row = insertedItem;
      //console.log(row.find.attr('id'));
      console.log(row);
      id = row.children('td').children([0]).children([0]).attr('id')
      console.log(id);
    })
    .bind('railsAutocomplete.select', function(event, data) {
      //console.log(data);
      dataId = data.item.id;
      dataValue = data.item.value;
      $("input[id='" + id + "']").val(dataValue);
      $("input[id = '" + id.replace("product_sku_title", "product_id") + "']").val(dataId);
    });
}

// калькулятор по позициям и итого
function calculate(val) {
  console.log(val);
  var table_lines = $('#kp_products tbody tr'); // это нужно чтобы ошибки не выскакивали в js
  if (table_lines.length >= 1) {
    for (var i = 0; i < table_lines.length; i++) {
      var row = table_lines[i];
      //console.log(row);
      var quantity = row.cells[1].firstChild.firstChild.value;
      var price = row.cells[2].firstChild.firstChild.value;
      var sum = quantity * price;
      row.cells[3].firstChild.firstChild.value = sum.toFixed(2);
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
  // пересчет суммы при изменении поля extra
  $("#kp_extra").on('change', function() {
    var extraValue = $(this).val();
    var table_lines = $('#kp_products tbody tr');
    var value = (extraValue / table_lines.length).toFixed(2);
    if (table_lines.length >= 1) {
      for (var i = 0; i < table_lines.length; i++) {
        var row = table_lines[i];
        //console.log(row);
        var price = row.cells[2].firstChild.firstChild.value;
        var newPrice = parseInt(price) + parseInt(value);
        row.cells[2].firstChild.firstChild.value = newPrice.toFixed(2);
      };
    }
    calculate();
  });

  // автокомплит
  $('.kp_kp_products_product_title input').bind('railsAutocomplete.select', function(event, data) {
    /* Do something here */
    //console.log($(this).attr('id'));
    //console.log(event);
    //console.log(data.item);
    idNode = $(this).attr('id');
    dataId = data.item.id;
    $("input[id = '" + idNode.replace("product_sku_title", "product_id") + "']").val(dataId);

  });

});
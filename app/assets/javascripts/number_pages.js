function check_first_page() {

  var x = document.location.search.substring(1).split('&');
  //document.getElementById("pdf_console_output").textContent += x;

  for (var i in x) {
    //console.log('hi');
    var pagetype = x[i].split('=', 2);
    if (pagetype[0] == "page") {
      pagenumber = Number(x[i].split('=', 2)[1])
      if (pagenumber == 1) {
        document.getElementsByClassName("headerContent")[0].style.display = "none";
      }
      /*
              if(pagenumber == 2 ){
              document.getElementsByClassName("headerContent")[0].style.display = "block";
              }
              if(pagenumber == 3 ){
              document.getElementsByClassName("headerContent")[0].style.display = "block";
              }
              if(pagenumber == 4 ){
              document.getElementsByClassName("headerContent")[0].style.display = "block";
              }
              if(pagenumber == 5 ){
              document.getElementsByClassName("headerContent")[0].style.display = "block";
              }
      */
    }
  }
}

function number_pages() {
  console.log('hi');
  var vars = {};
  var x = document.location.search.substring(1).split('&');
  console.log(x);
  for (var i in x) {
    var z = x[i].split('=', 2);
    console.log(z);
    vars[z[0]] = decodeURIComponent(z[1]);
  }
  var x = ['frompage', 'topage', 'page', 'webpage', 'section', 'subsection', 'subsubsection'];
  for (var i in x) {
    var y = document.getElementsByClassName(x[i]);
    console.log(y);
    for (var j = 0; j < y.length; ++j) y[j].textContent = vars[x[i]];
  }
}

function loadPage() {
  document.getElementById('status').style.display = 'block';

  document.getElementById("pdf_console_output").style.display = 'block';;
  document.getElementById("pdf_console_output").style.color = 'blue';
  // var text = document.createTextNode(" - This just got added - ");
  // document.getElementById("pdf_console_output").appendChild(text);
  var x = document.location.search.substring(1).split('&');
  for (var i in x) {
    var pagetype = x[i].split('=', 2);
    document.getElementById("pdf_console_output").appendChild(pagetype);
  }
}
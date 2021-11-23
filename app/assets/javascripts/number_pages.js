function my_number_pages() {

  var x = document.location.search.substring(1).split('&');
  for (var i in x) {
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
$(document).ready(function() {
  // Retrieve Session Variable
  var host = sessionStorage.getItem("host");
  var port = sessionStorage.getItem("port");

  // If session variables are not set or is null, force the user to enter data
  if ((!sessionStorage.getItem("host")) || (sessionStorage.getItem("host") == "")) {
    window.location.href = "index.html";
  }
  if ((!sessionStorage.getItem("port")) || (sessionStorage.getItem("port") == "")) {
    window.location.href = "index.html";
  }

  $.ajax({
    type: "POST",
    url: "http://" + host + ":" + port, //localhost:33939/",
    dataType: 'json',
    data: "local Q = require 'Q'; local meta_table, meta_json = Q.view_meta(); return meta_json",
    success: function(rd) {
      console.log(rd);

      // Make customised table
      $.makeTable = function(jsonData) {
        var table = $('<table id="MetaData" class="display"  style="word-wrap: break-word"><thead> <tr><th>vector</  th><th>field_type</th><th>chunk size</th> </tr></thead><tfoot> <tr><th>vector</  th><th>field_type</th><th>chunk size</th> </tr></tfoot>');
        for (var k in jsonData[0])
          tblHeader += "<th>" + k[0] + "</th>";
        $.each(jsonData, function(index, value) {
          var TableRow = "<tr>";
          TableRow += "<td><a href='view_meta_details.html?v=" + index + "'>" + index + "</td>";
          TableRow += "<td>" + value['base']['field_type'] + "</td>";
          TableRow += "<td>" + value['base']['chunk_size'] + "</td>";
          TableRow += "</tr>";
          $(table).append(TableRow);
        });
        return ($(table));
      };
      var jsonData = eval(rd);
      var table = $.makeTable(jsonData);
      $(table).appendTo("#show-data");
      $('#MetaData').DataTable({
        "order": [
          [0, "asc"]
        ]
      });
    }
  });

});

$(document).ready(function() {
  function getSearchParams(k) {
    var p = {};
    location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(s, k, v) {
      p[k] = v
    })
    return k ? p[k] : p;
  }
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
    data: "local Q = require 'Q' local meta_table, meta_json = Q.view_meta() return meta_json",
    success: function(data) {
      // For Debugiing: 
      //console.log(data);
      var vec = getSearchParams("v");
      // Make customised table
      $.makeTable = function(jsonData) {
        var table = $('<table id="myTable" class="table table-striped table-condensed" style="word-wrap: break-word"><thead> <tr><th>key</th><th>value</th> </tr></thead>');
        var TableRow = "<tr>";
        for (var k in jsonData)
          //tblHeader += "<th>" + k[0] + "</th>";
          if (k == vec) {
            console.log("key : " + k + " - value : " + jsonData[k]);
            console.log(jsonData[vec]);
            for (var key in jsonData[vec])
              if (key == 'base') {
                $.each(jsonData[vec]['base'], function(index, value) {
                  TableRow += "<tr>";
                  TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>" + index + "</td>";
                  TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>" + value + "</td>";
                  TableRow += "</tr>";
                });
              }
            if (key == 'aux') {
              $.each(jsonData[vec]['aux'], function(index, value) {
                TableRow += "<tr>";
                TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>aux:" + index + "</td>";
                TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>" + value + "</td>";
                TableRow += "</tr>";
              });
            }
            $(table).append(TableRow);
          }
        return ($(table));
      };
      var jsonData = eval(data);
      var table = $.makeTable(jsonData);
      $(table).appendTo("#show-data");
    }
  });
});

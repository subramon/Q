// Check if the localStorage object exists
if (localStorage) {
  $(document).ready(function() {
    $("#submit").click(function() {
      // Get input name
      var host = $("#host").val();
      var port = $("#port").val();

      // Store data
      sessionStorage.setItem("host", host);
      sessionStorage.setItem("port", port);
      window.location.href = "home.html";
    });
  });
} else {
  alert("Sorry, your browser do not support local storage.");
}

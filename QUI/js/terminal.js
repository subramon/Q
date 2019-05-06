var host = sessionStorage.getItem("host");
var port = sessionStorage.getItem("port");
// If session variables are not set or is null, force the user to enter data
if ((!sessionStorage.getItem("host")) || (sessionStorage.getItem("host") == "")) {
  window.location.href = "index.html";
}
if ((!sessionStorage.getItem("port")) || (sessionStorage.getItem("port") == "")) {
  window.location.href = "index.html";
}

function getParameterByName(name, url) {
  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, "\\$&");
  var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function postRequest() {
  var data =
    document.getElementById("input").value;
  addOption();
  if (data === "") {
    alert("Invalid input");
    return;
  }
  var xhr = new XMLHttpRequest();
  xhr.addEventListener("readystatechange", function() {
    if (this.readyState === 4) {
      document.getElementById("output").innerHTML = "<h4>" + this.responseText + "</h4>";
    }
  });
  // Retrieve Session Variable
  xhr.open("POST", "http://" + host + ":" + port);
  xhr.send(data);
}

function addOption() {
  var option = document.createElement("option");
  option.text = document.getElementById("input").value;
  console.log("INPUT" + option.text);
  if (!optionExists(document.getElementById("input").value, document.getElementById("past"))) {
    document.getElementById("past").size = document.getElementById("past").size + 1;
    document.getElementById("past").add(option);
    commands = localStorage.getItem("commands") + option.text + "____";
    commands = localStorage.setItem("commands", commands);
  }
}

function clearHistory() {
  localStorage.removeItem("commands");
  document.getElementById('past').innerHTML = "";
  commands = "";
  document.getElementById("past").size = 0;
  initialize();
}

function choose() {
  var select = document.getElementById("past");
  var _value = select.options[select.selectedIndex].value;
  document.getElementById("input").value = _value;
}

function optionExists(needle, haystack) {
  var optionExists = false;
  var optionsLength = haystack.length;
  while (optionsLength--) {
    if (haystack.options[optionsLength].value === needle) {
      optionExists = true;
      break;
    }
  }
  return optionExists;
}

function initialize() {
  if (localStorage.getItem("commands") !== null) {
    commands = localStorage.getItem("commands");
    commands = commands.slice(0, -4);
    var items = commands.split('____');
    for (var index = 0; index < items.length; index++) {
      var option = document.createElement("option");
      option.text = items[index].replace("null", "");
      document.getElementById("past").size = document.getElementById("past").size + 1;
      document.getElementById("past").add(option);
    }
  } else {
    commands = "";
  }
}

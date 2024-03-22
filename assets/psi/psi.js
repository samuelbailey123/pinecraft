// Define a function to perform the ajax call
function queryServerInfo(query, targetElementId, interval) {
  var queryAndUpdate = function () {
    $.ajax({
      url: "ajax.php",
      data: { query: query },
      type: "POST",
      success: function (data) {
        $("#" + targetElementId).html(data);
      },
    });
  };

  queryAndUpdate(); // Call immediately on page load

  if (interval) {
    setInterval(queryAndUpdate, interval); // Set interval for refreshing the data
  }
}

$(document).ready(function () {
  queryServerInfo("uptime", "uptime", 1000); // Refresh every second
  queryServerInfo("running", "running", 5000); // Refresh every 5 seconds
  queryServerInfo("load", "load", 30000); // Refresh every 30 seconds

  // Size and DF are refreshed together every 30 minutes
  queryServerInfo("size", "size", 1800000);
  queryServerInfo("df", "df", 1800000);
});

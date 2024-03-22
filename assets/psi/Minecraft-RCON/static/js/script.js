$(document).ready(function () {
  $("#txtCommand").bind("enterKey", function (e) {
    sendCommand($("#txtCommand").val());
  });

  $("#txtCommand").keyup(function (e) {
    if (e.keyCode == 13) {
      $(this).trigger("enterKey");
      $(this).val("");
    }
  });

  $("#btnSend").click(function () {
    if ($("#txtCommand").val() !== "") {
      $("#btnSend").prop("disabled", true);
    }
    sendCommand($("#txtCommand").val());
  });

  $("#btnClearLog").click(function () {
    $("#groupConsole").empty();
    alertInfo("Console has cleared.");
  });

  var autocompleteCommands = [
    // ...same array of commands
  ].sort();

  $("#txtCommand").autocomplete({
    source: autocompleteCommands,
    appendTo: "#txtCommandResults",
    open: function () {
      var position = $("#txtCommandResults").position(),
        left = position.left,
        top = position.top,
        width = $("#txtCommand").width(),
        height = $("#txtCommandResults > ul").height();

      $("#txtCommandResults > ul").css({
        left: left + "px",
        top: top - height - 4 + "px",
        width: width + 43 + "px",
      });
    },
  });

  function logMsg(msg, sep, cls) {
    var date = new Date(),
      datetime =
        ("0" + date.getDate()).slice(-2) +
        "-" +
        ("0" + (date.getMonth() + 1)).slice(-2) +
        "-" +
        date.getFullYear() +
        " @ " +
        ("0" + date.getHours()).slice(-2) +
        ":" +
        ("0" + date.getMinutes()).slice(-2) +
        ":" +
        ("0" + date.getSeconds()).slice(-2);

    $("#groupConsole").append(
      '<li class="list-group-item list-group-item-' +
        cls +
        '">' +
        '<span class="pull-right label label-' +
        cls +
        '">' +
        datetime +
        "</span>" +
        "<strong>" +
        sep +
        "</strong> " +
        msg +
        '<div class="clearfix"></div></li>',
    );

    $("#btnSend").prop("disabled", false);

    // Clear old logs if more than 50
    if ($("#groupConsole li").length > 50) {
      $("#groupConsole li:first").remove();
    }

    // Scroll down if auto-scroll is checked
    if ($("#chkAutoScroll").is(":checked")) {
      var panelBody = $("#consoleContent .panel-body");
      panelBody.scrollTop(panelBody.prop("scrollHeight"));
    }
  }

  // ...same function definitions for logSuccess, logInfo, logWarning, logDanger,
  // alertMsg, alertSuccess, alertInfo, alertWarning, alertDanger

  function sendCommand(command) {
    if (!command) {
      alertDanger("Command missing.");
      return;
    }
    logMsg(command, ">", "success");

    $.post("rcon/index.php", { cmd: command })
      .done(function (json) {
        // ...unchanged code for handling ajax response
      })
      .fail(function () {
        alertDanger("RCON error.");
        logDanger("RCON error.");
      });
  }
});

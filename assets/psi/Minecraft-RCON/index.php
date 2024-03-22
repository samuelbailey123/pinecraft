<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Minecraft RCON</title>
  <link rel="stylesheet" href="static/css/bootstrap.min.css">
  <link rel="stylesheet" href="static/css/style.css">
  <script src="static/js/jquery-1.12.0.min.js"></script>
  <script src="static/js/jquery-migrate-1.2.1.min.js"></script>
  <script src="static/js/jquery-ui-1.12.0.min.js"></script>
  <script src="static/js/bootstrap.min.js"></script>
  <script src="static/js/script.js"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" href="data:image/png;base64,..." type="image/png">
</head>
<body>
  <div id="content" class="container-fluid">
    <div id="alertMessage" class="alert alert-info">
      Minecraft RCON
    </div>
    <div id="consoleRow">
      <div id="consoleContent" class="panel panel-default">
        <div class="panel-heading">
          <h3 class="panel-title pull-left">
            <span class="glyphicon glyphicon-console"></span> Console
          </h3>
          <div class="btn-group btn-group-xs pull-right">
            <a class="btn btn-default" href="http://minecraft.gamepedia.com/Commands" target="_blank">
              <span class="glyphicon glyphicon-question-sign"></span><span class="hidden-xs"> Commands</span>
            </a>
            <a class="btn btn-default" href="http://www.minecraftinfo.com/idlist.htm" target="_blank">
              <span class="glyphicon glyphicon-info-sign"></span><span class="hidden-xs"> Items IDs</span>
            </a>
          </div>
        </div>
        <div class="panel-body">
          <ul id="groupConsole" class="list-group"></ul>
        </div>
      </div>
      <div id="consoleCommand" class="input-group">
        <span class="input-group-addon">
          <input id="chkAutoScroll" type="checkbox" checked autocomplete="off" /><span class="glyphicon glyphicon-arrow-down"></span>
        </span>
        <div id="txtCommandResults"></div>
        <input id="txtCommand" type="text" class="form-control" />
        <div class="input-group-btn">
          <button id="btnSend" type="button" class="btn btn-primary">
            <span class="glyphicon glyphicon-send"></span><span class="hidden-xs"> Send</span>
          </button>
          <button id="btnClearLog" type="button" class="btn btn-warning">
            <span class="glyphicon glyphicon-erase"></span><span class="hidden-xs"> Clear</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</body>
</html>

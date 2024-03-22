<?php
header("Content-type: application/json");

require "rcon.php";
require "../config.php";

$host = $rconHost;
$port = $rconPort;
$password = $rconPassword;
$timeout = 3;

$response = [];
$rcon = new Rcon($host, $port, $password, $timeout);

if (!isset($_POST["cmd"])) {
    $response = [
        "status" => "error",
        "error" => "Empty command",
    ];
} else {
    if ($rcon->connect()) {
        $command = $_POST["cmd"];
        $rcon->send_command($command);

        $response = [
            "status" => "success",
            "command" => $command,
            "response" => parseMinecraftColors($rcon->get_response()),
        ];
    } else {
        $response = [
            "status" => "error",
            "error" => "RCON connection error",
        ];
    }
}

echo json_encode($response);

function parseMinecraftColors($string)
{
    $string = utf8_decode(htmlspecialchars($string, ENT_QUOTES, "UTF-8"));
    $count = 0;

    $colorPattern = '/\xA7([0-9a-f])/i';
    $formatPattern = '/\xA7([k-or])/i';

    $string =
        preg_replace(
            $colorPattern,
            '<span class="mc-color mc-$1">',
            $string,
            -1,
            $colorCount
        ) . str_repeat("</span>", $colorCount);

    $string =
        preg_replace(
            $formatPattern,
            '<span class="mc-$1">',
            $string,
            -1,
            $formatCount
        ) . str_repeat("</span>", $formatCount);

    return utf8_encode($string);
}
?>

<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Check if user is authorized
function auth()
{
    // Check if 'auth' key is set in $_SESSION and equals 1
    return isset($_SESSION["auth"]) && $_SESSION["auth"] == 1;
}

// Load the master config file
function loadConfig()
{
    $cfgfile = "/etc/pinecraft/psi/psi.json";
    $config = json_decode(file_get_contents($cfgfile));
    $config->cfgfile = $cfgfile;
    return $config;
}

// Check if the game server is running
function running()
{
    $config = loadConfig();
    $serverPort = $config->server->{'server-port'};
    $connection = @fsockopen("localhost", $serverPort);

    if (is_resource($connection)) {
        fclose($connection);
        return true;
    }
    return false;
}

// Convert Bytes to Other, Automatically
// From https://stackoverflow.com/a/2510459
function formatBytes($bytes, $precision = 2)
{
    $units = ["B", "KB", "MB", "GB", "TB"];

    $bytes = max($bytes, 0);
    $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
    $pow = min($pow, count($units) - 1);

    // Avoid using bitwise shifts as it can cause issues on large numbers
    $bytes /= pow(1024, $pow);

    return round($bytes, $precision) . " " . $units[$pow];
}

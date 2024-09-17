<?php

require_once __DIR__ . '/../vendor/autoload.php';

// Definir la ruta base del proyecto
define('BASE_PATH', realpath(dirname(__FILE__) . '/..'));

// Usar la ruta base para incluir los archivos
$lastJoinedUsers = (require BASE_PATH . "/dic/users.php")->getLastJoined();

switch (require BASE_PATH . "/dic/negotiated_format.php") {
    case "text/html":
        (new Views\Layout(
            "Twitter - Newcomers", new Views\Users\Listing($lastJoinedUsers), true
        ))();
        exit;

    case "application/json":
        header("Content-Type: application/json");
        echo json_encode($lastJoinedUsers);
        exit;
}

http_response_code(406);
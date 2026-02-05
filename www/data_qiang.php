<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
header('Content-Type: application/json');

$servername = "localhost";
$username = "vlad";    // замени на своего пользователя
$password = "";        // замени на свой пароль
$dbname = "gdelt_db";

// Подключение к MySQL
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(['error' => $conn->connect_error]));
}

$sql = "SELECT datetime, rolling_avg_90d FROM mart_qiang ORDER BY datetime ASC";
$result = $conn->query($sql);

$data = ['datetime' => [], 'rolling_avg_90d' => []];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data['datetime'][] = $row['datetime'];
        $data['rolling_avg_90d'][] = floatval($row['rolling_avg_90d']);
    }
}

$conn->close();
echo json_encode($data);
?>
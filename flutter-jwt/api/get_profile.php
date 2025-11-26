<?php
require_once '../config/database.php';
require_once '../config/jwt_helper.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        "success" => false,
        "message" => "Method not allowed. Use GET."
    ]);
    exit();
}

// Get JWT token from Authorization header
$token = JWTHelper::getBearerToken();

if (empty($token)) {
    http_response_code(401);
    echo json_encode([
        "success" => false,
        "message" => "Access denied. No token provided."
    ]);
    exit();
}

// Validate token
$decoded = JWTHelper::validateToken($token);

if (!$decoded) {
    http_response_code(401);
    echo json_encode([
        "success" => false,
        "message" => "Access denied. Invalid or expired token."
    ]);
    exit();
}

// Create database connection
$database = new Database();
$db = $database->getConnection();

if ($db === null) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed."
    ]);
    exit();
}

try {
    // Get user data from token
    $userId = $decoded['data']['userId'];
    
    // Fetch user profile
    $query = "SELECT id, username, name FROM login WHERE id = :id LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $userId);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Profile retrieved successfully.",
            "data" => [
                "userId" => $row['id'],
                "username" => $row['username'],
                "name" => $row['name']
            ]
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            "success" => false,
            "message" => "User not found."
        ]);
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error retrieving profile: " . $e->getMessage()
    ]);
}
?>

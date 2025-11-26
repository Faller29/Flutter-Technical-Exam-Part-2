<?php
require_once '../config/database.php';
require_once '../config/jwt_helper.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        "success" => false,
        "message" => "Method not allowed. Use POST."
    ]);
    exit();
}

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate input
if (empty($data->username) || empty($data->password)) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Username and password are required."
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
    // Prepare query
    $query = "SELECT id, username, password, name FROM login WHERE username = :username LIMIT 1";
    $stmt = $db->prepare($query);
    
    // Bind parameters
    $stmt->bindParam(':username', $data->username);
    
    // Execute query
    $stmt->execute();
    
    // Check if user exists
    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Verify password (assuming password is stored as plain text in your current setup)
        // NOTE: In production, use password_hash() and password_verify()
        if ($data->password === $row['password']) {
            // Generate JWT token
            $token = JWTHelper::generateToken(
                $row['id'],
                $row['username'],
                $row['name']
            );
            
            http_response_code(200);
            echo json_encode([
                "success" => true,
                "message" => "Login successful.",
                "data" => [
                    "token" => $token,
                    "userId" => $row['id'],
                    "username" => $row['username'],
                    "name" => $row['name']
                ]
            ]);
        } else {
            http_response_code(401);
            echo json_encode([
                "success" => false,
                "message" => "Invalid username or password."
            ]);
        }
    } else {
        http_response_code(401);
        echo json_encode([
            "success" => false,
            "message" => "Invalid username or password."
        ]);
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Login failed: " . $e->getMessage()
    ]);
}
?>

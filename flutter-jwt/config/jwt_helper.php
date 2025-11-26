<?php
class JWTHelper {
    private static $secret_key = "your-secret-key-change-this-in-production";
    private static $issuer = "flutter-jwt-app";
    private static $audience = "flutter-app";
    
    // Base64 URL encode
    private static function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
    
    // Base64 URL decode
    private static function base64UrlDecode($data) {
        return base64_decode(strtr($data, '-_', '+/'));
    }
    
    // Generate JWT token
    public static function generateToken($userId, $username, $name) {
        $issuedAt = time();
        $expirationTime = $issuedAt + 3600; // Token valid for 1 hour
        
        // Create token header
        $header = json_encode([
            'typ' => 'JWT',
            'alg' => 'HS256'
        ]);
        
        // Create token payload
        $payload = json_encode([
            'iss' => self::$issuer,
            'aud' => self::$audience,
            'iat' => $issuedAt,
            'exp' => $expirationTime,
            'data' => [
                'userId' => $userId,
                'username' => $username,
                'name' => $name
            ]
        ]);
        
        // Encode Header
        $base64UrlHeader = self::base64UrlEncode($header);
        
        // Encode Payload
        $base64UrlPayload = self::base64UrlEncode($payload);
        
        // Create Signature
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret_key, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        // Create JWT
        $jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
        
        return $jwt;
    }
    
    // Validate JWT token
    public static function validateToken($token) {
        if (empty($token)) {
            return false;
        }
        
        // Split the token
        $tokenParts = explode('.', $token);
        if (count($tokenParts) != 3) {
            return false;
        }
        
        $header = base64_decode($tokenParts[0]);
        $payload = base64_decode($tokenParts[1]);
        $signatureProvided = $tokenParts[2];
        
        // Verify the signature
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret_key, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        if ($base64UrlSignature !== $signatureProvided) {
            return false;
        }
        
        // Check expiration
        $payloadData = json_decode($payload, true);
        if (isset($payloadData['exp']) && $payloadData['exp'] < time()) {
            return false;
        }
        
        return $payloadData;
    }
    
    // Get token from header
    public static function getBearerToken() {
        $headers = null;
        
        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER["Authorization"]);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
        } elseif (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            $requestHeaders = array_combine(
                array_map('ucwords', array_keys($requestHeaders)),
                array_values($requestHeaders)
            );
            
            if (isset($requestHeaders['Authorization'])) {
                $headers = trim($requestHeaders['Authorization']);
            }
        }
        
        // Extract the token
        if (!empty($headers)) {
            if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
                return $matches[1];
            }
        }
        
        return null;
    }
}
?>

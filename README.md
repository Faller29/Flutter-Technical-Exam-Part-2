# Flutter Technical Exam Part 2

## Prerequisites

- Flutter SDK
- PHP 7.0 or higher
- MySQL Database
- Local server (XAMPP, WAMP, MAMP)
- I personally recommend XAMPP as i used XAMPP when developing and testing

## Backend Setup

1. Copy the `flutter-jwt` folder to your web server directory:
   - XAMPP: `C:\xampp\htdocs\flutter-jwt`
   - WAMP: `C:\wamp64\www\flutter-jwt`
   - MAMP: `/Applications/MAMP/htdocs/flutter-jwt`

2. Start your XAMPP server run this:

run the .sql file in database folder of `flutter-jwt`

OR 

```sql
CREATE DATABASE flutter_jwt;
USE flutter_jwt;

CREATE TABLE login (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL
);

INSERT INTO login (username, password, name) VALUES
('admin', 'admin123', 'Administrator'),
('user', 'user123', 'Regular User');
```

Note: Passwords are stored as plain text for demo purposes only. In production, we use hashed/encrypted for security

3. Start Apache and MySQL from your local server

Login credentials: `admin/admin123` or `user/user123`

## How to Run Flutter

```bash
cd login_jwt
flutter pub get
flutter run
```

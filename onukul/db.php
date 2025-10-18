<?php
// db.php — PDO connection helper (drop-in)
declare(strict_types=1);

function pdo(): PDO {
  static $pdo = null;
  if ($pdo instanceof PDO) return $pdo;

  $host = getenv('DB_HOST') ?: '127.0.0.1';
  $db   = getenv('DB_NAME') ?: 'onukul';
  $user = getenv('DB_USER') ?: 'root';
  // Try empty password first, then 'root' (common on MAMP)
  $pass = getenv('DB_PASS');
  $tries = [];
  if ($pass !== false) { $tries[] = $pass; }
  $tries[] = ''; $tries[] = 'root';

  $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
  $opt = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
  ];

  $last = null;
  foreach ($tries as $pw) {
    try { $pdo = new PDO($dsn, $user, $pw, $opt); return $pdo; }
    catch (Throwable $e) { $last = $e; }
  }
  http_response_code(500);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode(['error' => 'Database connection failed: '.$last->getMessage()]);
  exit;
}

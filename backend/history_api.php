<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

const DB_HOST = 'localhost';
const DB_NAME = 'db_kalkulator';
const DB_USER = 'root';
const DB_PASS = '';
const DB_CHARSET = 'utf8mb4';

function respond(array $payload, int $statusCode = 200): void
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function requestData(): array
{
    $raw = file_get_contents('php://input');
    $decoded = json_decode($raw ?: '{}', true);

    if (is_array($decoded)) {
        return $decoded;
    }

    return $_POST;
}

try {
    $pdo = new PDO(
        sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET),
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );

    $action = $_GET['action'] ?? ($_POST['action'] ?? (requestData()['action'] ?? 'list'));
    $data = requestData();

    if ($action === 'insert') {
        $statement = $pdo->prepare(
            'INSERT INTO history (expression, result, title, created_at) VALUES (:expression, :result, :title, :created_at)'
        );
        $statement->execute([
            ':expression' => (string)($data['expression'] ?? ''),
            ':result' => (string)($data['result'] ?? ''),
            ':title' => isset($data['title']) && $data['title'] !== '' ? (string)$data['title'] : null,
            ':created_at' => (string)($data['created_at'] ?? date('c')),
        ]);

        respond([
            'success' => true,
            'id' => (int)$pdo->lastInsertId(),
        ]);
    }

    if ($action === 'update_title') {
        $title = (string)($data['title'] ?? '');
        $updatedRows = 0;
        $targetId = (int)($data['id'] ?? 0);

        if ($targetId > 0) {
            $statement = $pdo->prepare('UPDATE history SET title = :title WHERE id = :id');
            $statement->execute([
                ':title' => $title,
                ':id' => $targetId,
            ]);
            $updatedRows = $statement->rowCount();
        }

        if ($updatedRows === 0) {
            $expression = (string)($data['expression'] ?? '');
            $result = (string)($data['result'] ?? '');
            $createdAt = (string)($data['created_at'] ?? '');

            if ($expression !== '' && $result !== '' && $createdAt !== '') {
                $fallback = $pdo->prepare(
                    'UPDATE history
                     SET title = :title
                     WHERE expression = :expression AND result = :result AND created_at = :created_at
                     ORDER BY id DESC
                     LIMIT 1'
                );
                $fallback->execute([
                    ':title' => $title,
                    ':expression' => $expression,
                    ':result' => $result,
                    ':created_at' => $createdAt,
                ]);
                $updatedRows = $fallback->rowCount();
            }
        }

        respond([
            'success' => true,
            'updated_rows' => $updatedRows,
        ]);
    }

    if ($action === 'clear') {
        $statement = $pdo->prepare('DELETE FROM history');
        $statement->execute();

        respond([
            'success' => true,
            'deleted_rows' => $statement->rowCount(),
        ]);
    }

    $rows = $pdo->query('SELECT id, expression, result, title, created_at FROM history ORDER BY id DESC')->fetchAll();

    respond([
        'success' => true,
        'data' => $rows,
    ]);
} catch (Throwable $throwable) {
    respond([
        'success' => false,
        'message' => $throwable->getMessage(),
    ], 500);
}
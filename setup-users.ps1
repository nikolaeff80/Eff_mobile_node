# setup-users.ps1 — исправленная версия

# Принудительно UTF-8 в консоли
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

$BASE_URL = "http://localhost:3000/users"

Write-Host "=== Создание тестовых пользователей ===" -ForegroundColor Cyan
Write-Host ""

function Create-User {
    param (
        [string]$fullName,
        [string]$birthDate,
        [string]$email,
        [string]$password,
        [string]$role = $null
    )

    # Добавляем время к дате, чтобы Prisma принял
    $birthDate = "$birthDate" + "T00:00:00.000Z"

    Write-Host "Создаём: $fullName ($email)" -ForegroundColor Yellow

    $body = @{
        fullName  = $fullName
        birthDate = $birthDate
        email     = $email
        password  = $password
    }

    if ($role) {
        $body["role"] = $role
    }

    $json = $body | ConvertTo-Json -Depth 10 -Compress

    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/register" `
            -Method Post `
            -ContentType "application/json" `
            -Body $json `
            -ErrorAction Stop

        $response | ConvertTo-Json -Depth 5
    }
    catch {
        Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
    }

    Write-Host ""
}

Write-Host "Обычные пользователи:" -ForegroundColor Green
Create-User "Alex Petrov"      "1992-03-14" "alexey@example.com"     "pass1234"
Create-User "Maria Sidorova"   "1998-07-22" "maria@example.com"      "qwerty456"
Create-User "Dmitry Ivanov"    "1987-11-05" "dmitry@example.com"     "secure789"

Write-Host "Администратор:" -ForegroundColor Green
Create-User "Batya admin"      "1980-01-01" "batya_admin@example.com"     "admin2025!" "ADMIN"

Write-Host ""
Write-Host "=== Логин и получение токенов ===" -ForegroundColor Cyan
Write-Host ""

function Login-And-Show-Token {
    param (
        [string]$email,
        [string]$password,
        [string]$label
    )

    Write-Host "$label ($email)" -ForegroundColor Yellow

    $body = @{
        email    = $email
        password = $password
    } | ConvertTo-Json -Compress

    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/login" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -ErrorAction Stop

        $token = $response.token
        if ($token) {
            Write-Host "Token: $token" -ForegroundColor Green
            Write-Host "Длина токена: $($token.Length) символов" -ForegroundColor DarkGreen
        }
        else {
            Write-Host "Токен не получен. Ответ: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
    }

    Write-Host ""
}

Login-And-Show-Token "alexey@example.com"    "pass1234"      "Алексей"
Login-And-Show-Token "maria@example.com"     "qwerty456"     "Мария"
Login-And-Show-Token "dmitry@example.com"    "secure789"     "Дмитрий"
Login-And-Show-Token "batya_admin@example.com"    "admin2025!"    "Админ"

Write-Host "Готово." -ForegroundColor Cyan
Write-Host "Используйте любой токен в заголовке:"
Write-Host "Authorization: Bearer <токен>"
#!/usr/bin/env bash

set -euo pipefail

BASE_URL="http://localhost:3000/users"

echo "=== Создание тестовых пользователей ==="
echo ""

create_user() {
    local fullName="$1"
    local birthDate="$2"
    local email="$3"
    local password="$4"
    local role="$5"

    echo "Создаём: $fullName ($email)"
    curl -s -X POST "$BASE_URL/register" \
        -H "Content-Type: application/json" \
        -d '{
            "fullName": "'"$fullName"'",
            "birthDate": "'"$birthDate"'",
            "email": "'"$email"'",
            "password": "'"$password"'"'"${role:+, \"role\": \"$role\"}"'
        }' | jq .
    echo ""
}

echo "Обычные пользователи:"
create_user "Алексей Петров"      "1992-03-14" "alexey@example.com"     "pass1234"
create_user "Мария Сидорова"      "1998-07-22" "maria@example.com"      "qwerty456"
create_user "Дмитрий Иванов"      "1987-11-05" "dmitry@example.com"     "secure789"

echo "Администратор:"
create_user "Администратор Система" "1980-01-01" "admin@system.local"   "admin2025!" "ADMIN"

echo ""
echo "=== Логин и получение токенов ==="
echo ""

login_and_show_token() {
    local email="$1"
    local password="$2"
    local label="$3"

    echo "$label ($email)"
    TOKEN=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "'"$email"'",
            "password": "'"$password"'"
        }' | jq -r '.token // "ERROR: " + .error')

    if [[ "$TOKEN" == ERROR:* ]]; then
        echo "$TOKEN"
    else
        echo "Token: $TOKEN"
        echo "Длина токена: ${#TOKEN} символов"
    fi
    echo ""
}

login_and_show_token "alexey@example.com"    "pass1234"      "Алексей"
login_and_show_token "maria@example.com"     "qwerty456"     "Мария"
login_and_show_token "dmitry@example.com"    "secure789"     "Дмитрий"
login_and_show_token "admin@system.local"    "admin2025!"    "Админ"

echo "Готово."
echo "Можно скопировать любой токен и использовать в заголовке:"
echo 'Authorization: Bearer <скопированный_токен>'
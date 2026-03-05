#!/usr/bin/env bash

set -euo pipefail

BASE_URL="http://localhost:3000/users"

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=== Создание тестовых пользователей ===${NC}\n"

create_user() {
    local fullName="$1"
    local birthDate="$2"
    local email="$3"
    local password="$4"
    local role="${5:-}"

    local isoBirthDate="${birthDate}T00:00:00.000Z"

    echo -e "${YELLOW}Создаём: $fullName ($email)${NC}"

    # Формируем JSON через jq, чтобы избежать проблем с кавычками и ролью
    local json_body
    json_body=$(jq -n \
        --arg fn "$fullName" \
        --arg bd "$isoBirthDate" \
        --arg em "$email" \
        --arg pw "$password" \
        --arg rl "$role" \
        '{fullName: $fn, birthDate: $bd, email: $em, password: $pw} + (if $rl != "" then {role: $rl} else {} end)')

    # Отправка запроса
    local response
    response=$(curl -s -X POST "$BASE_URL/register" \
        -H "Content-Type: application/json" \
        -d "$json_body") || { echo -e "${RED}Ошибка запроса${NC}"; return; }

    echo "$response" | jq .
    echo ""
}

echo -e "${GREEN}Обычные пользователи:${NC}"
create_user "Alex Petrov"      "1992-03-14" "alexey@example.com"     "pass1234"
create_user "Maria Sidorova"   "1998-07-22" "maria@example.com"      "qwerty456"
create_user "Dmitry Ivanov"    "1987-11-05" "dmitry@example.com"     "secure789"

echo -e "${GREEN}Администратор:${NC}"
create_user "Batya admin"      "1980-01-01" "batya_admin@example.com" "admin2025!" "ADMIN"

echo -e "${CYAN}=== Логин и получение токенов ===${NC}\n"

login_and_show_token() {
    local email="$1"
    local password="$2"
    local label="$3"

    echo -e "${YELLOW}$label ($email)${NC}"

    local login_json
    login_json=$(jq -n --arg em "$email" --arg pw "$password" '{email: $em, password: $pw}')

    local response
    response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "$login_json")

    local token
    token=$(echo "$response" | jq -r '.token // empty')

    if [[ -n "$token" ]]; then
        echo -e "${GREEN}Token: $token${NC}"
        echo -e "Длина токена: ${#token} символов"
    else
        echo -e "${RED}Токен не получен. Ответ:$(echo "$response" | jq -c .)${NC}"
    fi
    echo ""
}

login_and_show_token "alexey@example.com"    "pass1234"      "Алексей"
login_and_show_token "maria@example.com"     "qwerty456"     "Мария"
login_and_show_token "dmitry@example.com"    "secure789"     "Дмитрий"
login_and_show_token "batya_admin@example.com" "admin2025!"  "Админ"

echo -e "${CYAN}Готово.${NC}"
echo "Используйте любой токен в заголовке:"
echo "Authorization: Bearer <токен>"

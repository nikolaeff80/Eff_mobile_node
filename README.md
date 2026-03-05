# Сервис управления пользователями

Простой REST API для работы с пользователями: регистрация, авторизация, просмотр профиля, список пользователей (только админ) и блокировка (самого себя или админом).

## Стек технологий

- **Язык**: TypeScript
- **Фреймворк**: Express.js
- **СУБД**: PostgreSQL
- **ORM**: Prisma (с Driver Adapter для PostgreSQL)
- **Авторизация**: JWT + bcrypt (хэширование паролей)
- **Валидация**: Joi
- **Дополнительно**:
  - dotenv — переменные окружения
  - cors, helmet — базовая безопасность и кросс-доменные запросы
  - ts-node-dev — hot-reload в разработке

**Запрещено по ТЗ**: NestJS

## Структура проекта
    ```
    project-root/
    ├── prisma/
    │   └── schema.prisma          # Схема БД
    ├── src/
    │   ├── config/                # Конфигурации (JWT_SECRET и т.д.)
    │   ├── controllers/           # Обработчики HTTP-запросов
    │   ├── middlewares/           # Аутентификация, валидация, ошибки
    │   ├── routes/                # Роуты Express
    │   ├── services/              # Бизнес-логика и взаимодействие с БД
    │   ├── types/                 # Типы (JwtPayload и т.д.)
    │   ├── lib/                   # prisma клиент (рекомендуется вынести)
    │   ├── app.ts                 # Инициализация Express
    │   └── server.ts              # Запуск сервера
    ├── .env                       # Переменные окружения
    ├── .gitignore
    ├── package.json
    ├── tsconfig.json
    ├── README.md
    ├── setup-users.ps1            # Пример использования API (windows)
    └── setup-users.sh             # Пример использования API (Linux)
    ```

## Установка и запуск

### Требования

- Node.js ≥ 18
- PostgreSQL (локальный или Docker)
- npm / yarn / pnpm

### Шаги

1. Клонируйте репозиторий

    ```bash
    git clone https://github.com/nikolaeff80/Eff_mobile_node.git
    cd Eff_mobile_node

2. Установите зависимости
    ```bash
    npm install

3. Создайте файл .env и заполните:

    ```bash
    DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/db_eff_mobile?schema=public
    JWT_SECRET=your_very_long_and_secure_secret_key_here
    PORT=3000

4. Инициализируйте Prisma и примените миграции

    ```bash
    npx prisma generate
    npx prisma migrate dev --name init

5. Запустите сервер в режиме разработки

    ```bash
    npm run dev

6. Эндпойнты
    ```
    Метод  Путь              Описание                   Аутентификация      Права
    POST   /users/register   Регистрация пользователя         —               —   
    POST   /users/login      Авторизация → JWT токен          —               —
    GET    /users/:id        Получить пользователя по ID      Да            Себя или админ
    GET    /users            Список всех пользователей        Да            Только админ
    PATCH  /users/:id/block  Заблокировать пользователя       Да            Себя или админ
    ```
7. Запустите setup-users(ps1/sh) для демонстрации
   Примеры одиночных запросов (curl)

    - Регистрация:
    ```
    curl -X POST http://localhost:3000/users/register -H "Content-Type: application/json" -d '{"fullName":"Test User","birthDate":"2000-01-01T00:00:00.000Z","email":"test@example.com","password":"pass123"}'
    ```
    - Логин:
    ```
    curl -X POST http://localhost:3000/users/login -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"pass123"}'
    ```
    - Блокировка (замените <TOKEN> и <ID>):
    ```
    curl -X PATCH http://localhost:3000/users/<ID>/block -H "Authorization: Bearer <TOKEN>" -H "Content-Type: application/json"
    ```
   
8. Решения и практики:
    - Слои (controllers → services → prisma)
    - Разделение ответственности (Separation of Concerns)
    - Middleware для аутентификации и авторизации
    - Типобезопасность (TypeScript + Prisma генерированные типы)
    - Валидация входных данных (Joi)
    - Безопасность:
        - Хэширование паролей (bcrypt)
        - JWT с коротким сроком жизни
        - Проверка ролей и владения (isSelfOrAdmin)
        - Helmet + CORS
    - Обработка ошибок (централизованный error handler)
    - Исключение пароля из ответов
    - Логирование запросов Prisma (опционально в dev)
    - Готовность к тестам (структура позволяет легко добавить Jest + Supertest)


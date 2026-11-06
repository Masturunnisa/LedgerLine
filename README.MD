# LedgerLine

LedgerLine is a ledger-first financial application foundation. **This repository is Day 1 scaffolding, not a functioning banking or money-transfer system.** The dashboard contains illustrative data only; the backend currently provides health information and a limited JWT login foundation.

## Technology

- Java 25, Maven, Spring Boot 4.0.9
- Spring Security, Spring Data JPA, MySQL 8, Flyway
- React, Vite, Tailwind CSS, Axios
- JUnit 5

## Implemented foundation

- Backend code is rooted at `com.ledgerline`, with config, controller, service, repository, entity, DTO, enum, and exception packages.
- `POST /api/v1/auth/login` authenticates a provisioned user and returns a short-lived (15-minute) HS256 bearer token. No registration or user-provisioning API exists.
- `GET /actuator/health` and `GET /actuator/info` are public. All other backend routes require a valid JWT.
- BCrypt password encoding is configured.
- Flyway migration `V1__create_initial_schema.sql` defines users, accounts, account permissions, transactions, ledger entries, idempotency keys, and audit events.
- Monetary database columns use signed `BIGINT` paise; SQL checks reject negative account balances and nonpositive ledger/transaction amounts.
- The React dashboard clearly labels its static figures as sample data. Account, transfer, and statement routes explicitly state that they are not implemented.

These are schema and architecture foundations, **not proof** that transfers are balanced, concurrency-safe, permission-safe, immutable, or financially safe. Review [THREATS.MD](./THREATS.MD) before extending the project.

## Prerequisites

- JDK 25 (Maven compilation uses release 25)
- MySQL 8.0.16 or later (enforces the schema `CHECK` constraints)
- Node.js 20.19+ and npm

Create the `ledgerline_db` database and a dedicated local application user using your MySQL administration process. Grant only the database privileges needed for application access and Flyway migrations. Do not use a root account for the application.

## Run the backend (PowerShell)

Set the environment variables in the same PowerShell process used to run Maven. `DB_URL` defaults to `jdbc:mysql://localhost:3306/ledgerline_db`.

```powershell
cd .\backend\LedgerLine
$credential = Get-Credential -Message "Local LedgerLine MySQL account"
$env:DB_USERNAME = $credential.UserName
$env:DB_PASSWORD = $credential.GetNetworkCredential().Password
$env:JWT_SECRET = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))

.\mvnw.cmd test
.\mvnw.cmd spring-boot:run
```

The generated JWT secret is for local development. Use a securely managed, stable secret in each deployed environment; never commit it. The app will fail to start if the secret is missing, invalid Base64, or shorter than 256 bits. Flyway applies the initial schema on startup and Hibernate validates it; Hibernate does not create or update the schema.

Health endpoint: `http://localhost:8080/actuator/health`

Authentication endpoint: `POST http://localhost:8080/api/v1/auth/login` with JSON `{"email":"user@example.com","password":"..."}`. A user must already exist in `users` with a BCrypt hash and one of the defined roles. Provisioning is not implemented.

## Run the frontend (PowerShell)

```powershell
cd .\frontend
Copy-Item .env.example .env.local
npm install
npm run dev
```

Open the Vite URL printed in the terminal (typically `http://localhost:5173`). `VITE_API_BASE_URL` in `.env.local` configures the Axios base URL. The current dashboard does not request or show live account data; no authenticated frontend session flow is wired yet.

Production asset build:

```powershell
npm run build
```

## Tests and verification

Run backend tests with `.\mvnw.cmd test` from `backend\LedgerLine` and the frontend production build with `npm run build` from `frontend`. The unit tests do not require a live database. No integration test currently proves Flyway execution against MySQL, JWT endpoint behavior, or any financial invariant.

## Next steps

See the Day 2 recommendations in [THREATS.MD](./THREATS.MD): integration-test the migration and login, design safe provisioning, enforce account permissions, and implement transfers only alongside atomic ledger invariants, idempotency, and concurrency tests.

# AI-assisted development log

This log records work performed on the LedgerLine Day 1 foundation. Do not treat generated or planned behavior as verified behavior.

## Entry 1 — 06 November 2026

### Task
Inspect the existing repository and establish a minimal Java 25/Spring Boot and React foundation for LedgerLine without implementing unfinished financial workflows.

### Prompt summary
The user requested modular backend packages, MySQL environment configuration, Flyway tables, integer paise amounts, three roles, JWT/BCrypt foundations, health/auth endpoints, a React/Vite dashboard, setup documentation, initial tests, and explicit security-gap reporting. They prohibited placeholder application generation and unsupported claims of financial safety.

### Repository observations
- Existing backend files were mostly empty classes, used inconsistent package roots, and did not provide the requested migration.
- Existing datasource settings included a hardcoded local database username/password setting; these were replaced with environment-variable placeholders.
- Existing frontend JSX files were empty and there was no package manifest or runnable Vite setup.
- The initial Maven test command could not compile because the available JDK was version 23 while the project targets Java 25.

### Implemented
- Moved the application entry point into `com.ledgerline` and created focused config/controller/service/repository/entity/DTO/enum/exception packages.
- Added JWT login plumbing, role claims, BCrypt configuration, and a required environment-supplied HMAC secret. User provisioning and transaction APIs remain unimplemented.
- Added a Flyway initial schema using BIGINT paise and database constraints, plus a routed dashboard that labels its sample data and unimplemented pages.
- Replaced the setup and threat documentation with explicit status and security limitations.

### Verification
- Baseline: `.\mvnw.cmd -f .\LedgerLine\backend\LedgerLine\pom.xml test` stopped at Java compilation because JDK 23 does not support `--release 25`; tests did not run.
- Post-change backend tests and frontend build: pending.
- MySQL migration execution and runtime endpoint checks: not yet performed.

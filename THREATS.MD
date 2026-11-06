# LedgerLine threat register — Day 1

This register distinguishes database structures and security foundations from mitigations that have actually been implemented. Day 1 does **not** make LedgerLine safe for real financial use.

## 1. Duplicate or replayed transfers

- **Risk:** A retried or concurrent request moves money more than once.
- **Day 1 state:** `idempotency_keys` has a unique `(initiating_user_id, idempotency_key)` constraint and a request hash field. No transfer handler or idempotency processing exists.
- **Remaining work:** Define key lifecycle, request-hash conflict behavior, atomic persistence, expiry/retention, and retry responses. Test concurrent duplicate requests against MySQL.

## 2. Concurrent withdrawals and double-entry balance

- **Risk:** Competing transfers overspend an account, leave a partial ledger, or record unequal debit and credit entries.
- **Day 1 state:** Amounts are represented as `BIGINT` paise. `accounts.balance_paise` has a nonnegative `CHECK`, and ledger rows have positive-amount checks. There is no balance-update or transfer service.
- **Remaining work:** Design and test a database-transaction boundary, locking/conditional update strategy, and an invariant that a completed internal transfer has exactly equal debit and credit entries. Do not rely on an in-memory check or claim a concurrency guarantee before multi-connection tests pass.

## 3. Unauthorized account access

- **Risk:** A caller accesses an account without being its owner or authorized delegate.
- **Day 1 state:** The schema has `account_permissions`; the API does not expose account operations and no permission-check service exists. JWT roles do not by themselves authorize a specific account.
- **Remaining work:** Enforce permission checks on every backend read and write, test cross-user access denial, and avoid trusting UI checks.

## 4. Ledger or audit tampering

- **Risk:** Privileged application/database users alter or delete historical records.
- **Day 1 state:** Ledger and audit tables exist, but the schema does not prevent update/delete, hash-chain events, or separate database privileges.
- **Remaining work:** Use narrowly scoped database identities/privileges, append-only write paths, tamper evidence and operational monitoring; test that mutation is denied. A table name or ORM convention is not immutability.

## 5. Authentication and credential handling

- **Day 1 state:** Login uses BCrypt verification; a Base64 HMAC key is required from `JWT_SECRET` and must decode to at least 32 bytes. Tokens expire after 15 minutes and validate issuer, signature, and standard timestamps. The frontend has no login/session wiring.
- **Remaining work:** Implement safe user provisioning, rate limiting, secret rotation, token revocation/session policy, security event auditing, and production secret management. The HMAC key is shared by issuer and verifier.

## 6. AI and transaction execution

- **Day 1 state:** There is no AI integration and no transaction endpoint. The dashboard's example amounts and activity are static and visibly labeled illustrative.
- **Requirement:** AI must never autonomously initiate or approve financial transactions. Any future AI feature must remain advisory and require an authenticated, authorized human action through the backend.

## Day 1 verification boundary

Passing a compile or unit test is not evidence that these risks are mitigated. No real-money use, deployment, production security review, database migration integration test, or financial invariant test is claimed.

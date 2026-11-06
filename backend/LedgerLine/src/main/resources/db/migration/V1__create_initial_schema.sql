CREATE TABLE users (
    id BIGINT NOT NULL AUTO_INCREMENT,
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(60) NOT NULL,
    role VARCHAR(32) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN ('ADMIN', 'ACCOUNT_HOLDER', 'AUDITOR')),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB;

CREATE TABLE accounts (
    id BIGINT NOT NULL AUTO_INCREMENT,
    account_number VARCHAR(34) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'INR',
    balance_paise BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_accounts PRIMARY KEY (id),
    CONSTRAINT uk_accounts_account_number UNIQUE (account_number),
    CONSTRAINT chk_accounts_balance_nonnegative CHECK (balance_paise >= 0),
    CONSTRAINT chk_accounts_status CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED'))
) ENGINE=InnoDB;

CREATE TABLE account_permissions (
    user_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    permission VARCHAR(24) NOT NULL,
    granted_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_account_permissions PRIMARY KEY (user_id, account_id, permission),
    CONSTRAINT fk_account_permissions_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_account_permissions_account FOREIGN KEY (account_id) REFERENCES accounts (id),
    CONSTRAINT chk_account_permissions_permission CHECK (permission IN ('VIEW', 'TRANSFER', 'MANAGE'))
) ENGINE=InnoDB;

CREATE TABLE ledger_transactions (
    id BIGINT NOT NULL AUTO_INCREMENT,
    initiating_user_id BIGINT NOT NULL,
    source_account_id BIGINT NOT NULL,
    destination_account_id BIGINT NOT NULL,
    amount_paise BIGINT NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    completed_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_ledger_transactions PRIMARY KEY (id),
    CONSTRAINT fk_transactions_user FOREIGN KEY (initiating_user_id) REFERENCES users (id),
    CONSTRAINT fk_transactions_source FOREIGN KEY (source_account_id) REFERENCES accounts (id),
    CONSTRAINT fk_transactions_destination FOREIGN KEY (destination_account_id) REFERENCES accounts (id),
    CONSTRAINT chk_transactions_amount_positive CHECK (amount_paise > 0),
    CONSTRAINT chk_transactions_distinct_accounts CHECK (source_account_id <> destination_account_id),
    CONSTRAINT chk_transactions_status CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED')),
    INDEX ix_transactions_source_created (source_account_id, created_at),
    INDEX ix_transactions_destination_created (destination_account_id, created_at),
    INDEX ix_transactions_initiator_created (initiating_user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE ledger_entries (
    id BIGINT NOT NULL AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    direction VARCHAR(8) NOT NULL,
    amount_paise BIGINT NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_ledger_entries PRIMARY KEY (id),
    CONSTRAINT fk_ledger_entries_transaction FOREIGN KEY (transaction_id) REFERENCES ledger_transactions (id),
    CONSTRAINT fk_ledger_entries_account FOREIGN KEY (account_id) REFERENCES accounts (id),
    CONSTRAINT chk_ledger_entries_direction CHECK (direction IN ('DEBIT', 'CREDIT')),
    CONSTRAINT chk_ledger_entries_amount_positive CHECK (amount_paise > 0),
    CONSTRAINT uk_ledger_transaction_account UNIQUE (transaction_id, account_id),
    INDEX ix_ledger_entries_account_created (account_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE idempotency_keys (
    id BIGINT NOT NULL AUTO_INCREMENT,
    initiating_user_id BIGINT NOT NULL,
    idempotency_key VARCHAR(128) NOT NULL,
    request_hash CHAR(64) NOT NULL,
    transaction_id BIGINT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'IN_PROGRESS',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_idempotency_keys PRIMARY KEY (id),
    CONSTRAINT fk_idempotency_user FOREIGN KEY (initiating_user_id) REFERENCES users (id),
    CONSTRAINT fk_idempotency_transaction FOREIGN KEY (transaction_id) REFERENCES ledger_transactions (id),
    CONSTRAINT uk_idempotency_user_key UNIQUE (initiating_user_id, idempotency_key),
    CONSTRAINT chk_idempotency_status CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'FAILED'))
) ENGINE=InnoDB;

CREATE TABLE audit_events (
    id BIGINT NOT NULL AUTO_INCREMENT,
    actor_user_id BIGINT NULL,
    event_type VARCHAR(64) NOT NULL,
    target_type VARCHAR(64) NULL,
    target_id VARCHAR(128) NULL,
    details JSON NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT pk_audit_events PRIMARY KEY (id),
    CONSTRAINT fk_audit_events_actor FOREIGN KEY (actor_user_id) REFERENCES users (id) ON DELETE SET NULL,
    INDEX ix_audit_events_actor_created (actor_user_id, created_at),
    INDEX ix_audit_events_target (target_type, target_id)
) ENGINE=InnoDB;

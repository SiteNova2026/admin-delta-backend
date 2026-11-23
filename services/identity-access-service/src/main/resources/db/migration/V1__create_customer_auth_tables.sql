
-- =====================================================
-- 1. CUSTOMERS
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    full_name VARCHAR(150),

    email VARCHAR(255),
    phone_number VARCHAR(20),

    email_verified_at TIMESTAMPTZ,
    phone_verified_at TIMESTAMPTZ,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_customer_status
        CHECK (status IN ('ACTIVE', 'BLOCKED', 'DELETED')),

    CONSTRAINT chk_customer_contact
        CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

CREATE UNIQUE INDEX uq_customers_email
    ON customers (LOWER(email))
    WHERE email IS NOT NULL;

CREATE UNIQUE INDEX uq_customers_phone
    ON customers (phone_number)
    WHERE phone_number IS NOT NULL;


-- =====================================================
-- 2. CUSTOMER OAUTH ACCOUNTS
-- =====================================================

CREATE TABLE customer_oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    customer_id UUID NOT NULL
        REFERENCES customers(id) ON DELETE CASCADE,

    provider VARCHAR(30) NOT NULL,

    provider_user_id VARCHAR(255) NOT NULL,

    provider_email VARCHAR(255),

    provider_email_verified BOOLEAN NOT NULL DEFAULT FALSE,

    linked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_oauth_provider
        CHECK (provider IN ('GOOGLE')),

    CONSTRAINT uq_oauth_provider_user
        UNIQUE (provider, provider_user_id)
);

CREATE INDEX idx_oauth_customer_id
    ON customer_oauth_accounts(customer_id);


-- =====================================================
-- 3. OTP CHALLENGES
-- =====================================================

CREATE TABLE otp_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    destination VARCHAR(255) NOT NULL,

    channel VARCHAR(10) NOT NULL,

    purpose VARCHAR(30) NOT NULL DEFAULT 'LOGIN',

    otp_hash VARCHAR(255) NOT NULL,

    expires_at TIMESTAMPTZ NOT NULL,

    attempts SMALLINT NOT NULL DEFAULT 0,

    max_attempts SMALLINT NOT NULL DEFAULT 5,

    verified_at TIMESTAMPTZ,

    consumed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_otp_channel
        CHECK (channel IN ('EMAIL', 'SMS')),

    CONSTRAINT chk_otp_purpose
        CHECK (purpose IN ('LOGIN', 'REGISTER', 'LINK_ACCOUNT')),

    CONSTRAINT chk_otp_attempts
        CHECK (attempts >= 0 AND max_attempts > 0)
);

CREATE INDEX idx_otp_destination_created
    ON otp_challenges(destination, created_at DESC);

CREATE INDEX idx_otp_expiry
    ON otp_challenges(expires_at);


-- =====================================================
-- 4. CUSTOMER REFRESH TOKENS
-- =====================================================

CREATE TABLE customer_refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    customer_id UUID NOT NULL
        REFERENCES customers(id) ON DELETE CASCADE,

    token_hash VARCHAR(64) NOT NULL UNIQUE,

    token_family_id UUID NOT NULL,

    expires_at TIMESTAMPTZ NOT NULL,

    revoked_at TIMESTAMPTZ,

    replaced_by UUID,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_refresh_replaced_by
        FOREIGN KEY (replaced_by)
        REFERENCES customer_refresh_tokens(id)
);

CREATE INDEX idx_refresh_customer
    ON customer_refresh_tokens(customer_id);

CREATE INDEX idx_refresh_family
    ON customer_refresh_tokens(token_family_id);

CREATE INDEX idx_refresh_expiry
    ON customer_refresh_tokens(expires_at);

-- ============================================================
-- Schema: customers, orders, support_tickets
-- For multi-agent customer support system
-- ============================================================

-- CUSTOMERS
CREATE TABLE customers (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT,
    address     TEXT,
    plan        TEXT NOT NULL CHECK (plan IN ('basic', 'pro', 'enterprise')),
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_customers_email ON customers (email);

-- ORDERS
CREATE TABLE orders (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     BIGINT NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
    product_name    TEXT NOT NULL,
    quantity        INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price      NUMERIC(10, 2),
    total_amount    NUMERIC(10, 2),
    currency        TEXT NOT NULL DEFAULT 'USD',
    status          TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'returned')),
    order_date      TIMESTAMPTZ NOT NULL DEFAULT now(),
    delivery_date   TIMESTAMPTZ,
    return_eligible BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_orders_status ON orders (status);

-- SUPPORT TICKETS
CREATE TABLE support_tickets (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     BIGINT NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
    order_id        BIGINT REFERENCES orders (id) ON DELETE SET NULL,
    subject         TEXT NOT NULL,
    description     TEXT NOT NULL,
    category        TEXT NOT NULL
                        CHECK (category IN ('billing', 'returns', 'shipping', 'technical', 'general', 'account')),
    priority        TEXT NOT NULL DEFAULT 'medium'
                        CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status          TEXT NOT NULL DEFAULT 'open'
                        CHECK (status IN ('open', 'in_progress', 'waiting_on_customer', 'escalated', 'resolved', 'closed')),
    assigned_to     TEXT,
    resolution      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_support_tickets_customer_id ON support_tickets (customer_id);
CREATE INDEX idx_support_tickets_status ON support_tickets (status);
CREATE INDEX idx_support_tickets_category ON support_tickets (category);

-- RLS intentionally left disabled on all tables.
-- The MCP agent connects via service_role key.

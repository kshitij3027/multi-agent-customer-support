-- ============================================================
-- Seed data: 12 customers, 15 orders, 12 support tickets
-- ============================================================

-- CUSTOMERS (12)
INSERT INTO customers (name, email, phone, address, plan, status) VALUES
('Alice Johnson',    'alice@example.com',    '+1-555-0101', '123 Oak St, Austin, TX 78701',         'pro',        'active'),
('Bob Martinez',     'bob@example.com',      '+1-555-0102', '456 Elm Ave, Denver, CO 80202',        'basic',      'active'),
('Carol Chen',       'carol@example.com',    '+1-555-0103', '789 Pine Rd, Seattle, WA 98101',       'enterprise', 'active'),
('David Kim',        'david@example.com',    '+1-555-0104', '321 Maple Dr, Portland, OR 97201',     'pro',        'active'),
('Eva Patel',        'eva@example.com',      '+1-555-0105', '654 Cedar Ln, San Jose, CA 95101',     'basic',      'active'),
('Frank Wilson',     'frank@example.com',    '+1-555-0106', '987 Birch Blvd, Chicago, IL 60601',    'pro',        'active'),
('Grace Lee',        'grace@example.com',    '+1-555-0107', '147 Walnut St, Boston, MA 02101',      'enterprise', 'active'),
('Henry Adams',      'henry@example.com',    '+1-555-0108', '258 Spruce Ave, Miami, FL 33101',      'basic',      'inactive'),
('Ivy Nguyen',       'ivy@example.com',      '+1-555-0109', '369 Ash Ct, Nashville, TN 37201',      'pro',        'active'),
('Jack Thompson',    'jack@example.com',     '+1-555-0110', '471 Hickory Way, Phoenix, AZ 85001',   'enterprise', 'suspended'),
('Karen Brooks',     'karen@example.com',    '+1-555-0111', '582 Poplar Rd, Atlanta, GA 30301',     'basic',      'active'),
('Leo Rivera',       'leo@example.com',      '+1-555-0112', '693 Willow Dr, Dallas, TX 75201',      'pro',        'active');

-- ORDERS (15)
INSERT INTO orders (customer_id, product_name, quantity, unit_price, total_amount, currency, status, order_date, delivery_date, return_eligible) VALUES
-- Alice: overcharged USB-C cable (billing dispute scenario), old order → not return eligible
(1, 'USB-C Charging Cable',       2, 15.99,  31.98, 'USD', 'delivered',  '2025-10-15', '2025-10-22', false),
-- Bob: returned laptop stand
(2, 'Adjustable Laptop Stand',    1, 49.99,  49.99, 'USD', 'returned',   '2025-12-01', '2025-12-08', false),
-- Carol: enterprise software license (billing / invoice scenario)
(3, 'Enterprise Software License', 1, 999.00, 999.00, 'USD', 'confirmed', '2026-01-20', NULL,         false),
-- David: wireless earbuds delivered recently → eligible for return
(4, 'Wireless Earbuds Pro',       1, 79.99,  79.99, 'USD', 'delivered',  '2026-02-01', '2026-02-07', true),
-- Eva: pending keyboard order
(5, 'Mechanical Keyboard',        1, 129.99, 129.99, 'USD', 'pending',   '2026-02-10', NULL,         true),
-- Frank: shipped monitor
(6, 'Ultra-Wide Monitor 34"',     1, 449.99, 449.99, 'USD', 'shipped',   '2026-02-05', NULL,         true),
-- Grace: two orders — one delivered, one in transit
(7, 'Ergonomic Office Chair',     1, 299.99, 299.99, 'USD', 'delivered',  '2026-01-10', '2026-01-18', true),
(7, 'Standing Desk Mat',          2, 39.99,  79.98, 'USD', 'shipped',    '2026-02-08', NULL,         true),
-- Henry: cancelled order (inactive customer)
(8, 'Noise Cancelling Headphones', 1, 199.99, 199.99, 'USD', 'cancelled', '2026-01-05', NULL,        false),
-- Ivy: delivered webcam, eligible
(9, 'HD Webcam 1080p',            1, 59.99,  59.99, 'USD', 'delivered',  '2026-02-03', '2026-02-09', true),
-- Jack: pending order on suspended account
(10, 'Server Rack Mount Kit',     3, 85.00,  255.00, 'USD', 'pending',   '2026-02-12', NULL,         true),
-- Karen: two orders
(11, 'Wireless Mouse',            1, 29.99,  29.99, 'USD', 'delivered',  '2026-01-25', '2026-01-30', true),
(11, 'USB Hub 7-Port',            1, 24.99,  24.99, 'USD', 'delivered',  '2025-08-10', '2025-08-15', false),
-- Leo: delivered + shipped
(12, 'Portable SSD 1TB',          1, 109.99, 109.99, 'USD', 'delivered', '2026-02-02', '2026-02-08', true),
(12, 'Laptop Sleeve 15"',         1, 34.99,  34.99, 'USD', 'shipped',   '2026-02-11', NULL,         true);

-- SUPPORT TICKETS (12)
INSERT INTO support_tickets (customer_id, order_id, subject, description, category, priority, status, assigned_to, resolution) VALUES
-- Billing: Alice overcharged on USB cable
(1, 1,    'Overcharged on USB-C Cable order',
          'I was charged $31.98 but the website showed $25.98 at checkout. Please refund the $6.00 difference.',
          'billing', 'high', 'open', NULL, NULL),

-- Returns: Bob already returned laptop stand, wants refund status
(2, 2,    'Refund not received for returned Laptop Stand',
          'I returned the Adjustable Laptop Stand two weeks ago but have not received my refund yet. Tracking shows it was delivered back to warehouse.',
          'returns', 'medium', 'in_progress', 'returns-agent', NULL),

-- Billing: Carol wants invoice for enterprise license
(3, 3,    'Need invoice for Enterprise Software License',
          'Our accounting department requires a formal invoice with our company tax ID for the $999 software license purchase. Please send ASAP.',
          'billing', 'medium', 'open', NULL, NULL),

-- Returns: David wants to return earbuds (eligible)
(4, 4,    'Return request for Wireless Earbuds Pro',
          'The earbuds do not fit comfortably. I would like to initiate a return. They were delivered on Feb 7th and are in original packaging.',
          'returns', 'medium', 'open', NULL, NULL),

-- Billing: Eva asking about plan pricing
(5, NULL, 'Question about Pro plan pricing',
          'I am currently on the Basic plan and considering upgrading to Pro. Can you tell me the price difference and what additional features I get?',
          'billing', 'low', 'open', NULL, NULL),

-- Shipping: Frank monitor in transit
(6, 6,    'Monitor shipping delayed',
          'My Ultra-Wide Monitor was supposed to arrive by Feb 10 but tracking still shows in transit. Can you provide an updated delivery estimate?',
          'shipping', 'medium', 'open', NULL, NULL),

-- General: Grace delivery confirmation
(7, 7,    'Did not receive delivery confirmation email',
          'My Ergonomic Office Chair was delivered on Jan 18 but I never received a delivery confirmation email. Please resend it.',
          'general', 'low', 'resolved', 'support-agent', 'Resent delivery confirmation email to grace@example.com on Jan 20.'),

-- Account: Henry locked out (inactive)
(8, NULL, 'Cannot log in to my account',
          'I have been trying to log in for the past 3 days but keep getting "account inactive" error. I need to access my order history.',
          'account', 'high', 'escalated', NULL, NULL),

-- Technical: Ivy webcam setup issue
(9, 10,   'Webcam not detected on Mac',
          'My new HD Webcam is not being detected on my MacBook Pro running macOS Ventura. Tried multiple USB ports. Need help troubleshooting.',
          'technical', 'medium', 'waiting_on_customer', 'tech-agent', NULL),

-- Account: Jack suspended account (escalation scenario)
(10, NULL, 'Account suspended without notice',
           'My enterprise account was suddenly suspended. I have 3 pending orders and my team relies on this account. Please restore access immediately.',
           'account', 'urgent', 'escalated', NULL, NULL),

-- Returns: Karen ineligible return attempt (old order)
(11, 13,  'Want to return USB Hub',
          'I would like to return the USB Hub 7-Port I purchased. It is not compatible with my new laptop.',
          'returns', 'low', 'open', NULL, NULL),

-- Shipping: Leo tracking not updating
(12, 15,  'Laptop Sleeve tracking not updating',
          'The tracking number for my Laptop Sleeve order has not updated in 3 days. It still shows "label created". Is there an issue?',
          'shipping', 'medium', 'open', NULL, NULL);

-- ============================================
-- CLONMEL GLASS INVOICE HUB - SUPABASE SCHEMA
-- Updated: 2026-01-18
-- ============================================

-- 1. CREATE TABLES (IF THEY DON'T EXIST)
-- ============================================

-- Products Table
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC NOT NULL,
  unit TEXT DEFAULT 'sqm',
  category TEXT DEFAULT 'General'
);

-- Invoices Table
CREATE TABLE IF NOT EXISTS invoices (
  id TEXT PRIMARY KEY,
  invoice_number TEXT NOT NULL,
  customer_id TEXT,
  customer_name TEXT NOT NULL,
  customer_email TEXT,
  customer_phone TEXT,
  customer_address TEXT,
  company TEXT DEFAULT 'clonmel',
  items JSONB NOT NULL,
  subtotal NUMERIC NOT NULL,
  tax_rate NUMERIC NOT NULL,
  tax_amount NUMERIC NOT NULL,
  total NUMERIC NOT NULL,
  amount_paid NUMERIC DEFAULT 0,
  balance_due NUMERIC NOT NULL,
  status TEXT NOT NULL,
  date_issued TEXT NOT NULL,
  due_date TEXT NOT NULL,
  notes TEXT,
  created_by TEXT,
  last_reminder_sent TEXT
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL,
  avatar TEXT
);

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT,
  city TEXT,
  postal_code TEXT,
  country TEXT DEFAULT 'Ireland',
  company TEXT,
  notes TEXT,
  tags JSONB,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  created_by TEXT NOT NULL
);

-- Quotes Table (NEW)
CREATE TABLE IF NOT EXISTS quotes (
  id TEXT PRIMARY KEY,
  quote_number TEXT NOT NULL,
  customer_id TEXT,
  customer_name TEXT NOT NULL,
  customer_email TEXT,
  customer_phone TEXT,
  customer_address TEXT,
  company TEXT DEFAULT 'clonmel',
  items JSONB NOT NULL,
  subtotal NUMERIC NOT NULL,
  tax_rate NUMERIC NOT NULL,
  tax_amount NUMERIC NOT NULL,
  total NUMERIC NOT NULL,
  valid_until TEXT NOT NULL,
  date_issued TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING',
  notes TEXT,
  created_by TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- App Settings Table
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT
);

-- ============================================
-- 2. ADD MISSING COLUMNS (IF THEY DON'T EXIST)
-- ============================================

-- Add company column to invoices if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'invoices' AND column_name = 'company'
  ) THEN
    ALTER TABLE invoices ADD COLUMN company TEXT DEFAULT 'clonmel';
  END IF;
END $$;

-- Add customer_phone column to invoices if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'invoices' AND column_name = 'customer_phone'
  ) THEN
    ALTER TABLE invoices ADD COLUMN customer_phone TEXT;
  END IF;
END $$;

-- Add last_reminder_sent column to invoices if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'invoices' AND column_name = 'last_reminder_sent'
  ) THEN
    ALTER TABLE invoices ADD COLUMN last_reminder_sent TEXT;
  END IF;
END $$;

-- ============================================
-- 3. SEED INITIAL DATA
-- ============================================

-- Seed Admin User (if not exists)
INSERT INTO users (id, name, email, role, avatar)
VALUES ('u1', 'Admin User', 'admin@clonmel.com', 'ADMIN', 'https://i.pravatar.cc/150?u=admin')
ON CONFLICT (email) DO NOTHING;

-- Seed Regular User (if not exists)
INSERT INTO users (id, name, email, role, avatar)
VALUES ('u2', 'John Doe', 'john@clonmel.com', 'USER', 'https://i.pravatar.cc/150?u=john')
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- 4. PERMISSIONS (DISABLE RLS FOR DEVELOPMENT)
-- ============================================
-- Note: For production, you should enable RLS and create proper policies

ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE invoices DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE quotes DISABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- ============================================

-- Invoices indexes
CREATE INDEX IF NOT EXISTS idx_invoices_customer_id ON invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_due_date ON invoices(due_date);
CREATE INDEX IF NOT EXISTS idx_invoices_date_issued ON invoices(date_issued);

-- Customers indexes
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_created_by ON customers(created_by);

-- Quotes indexes
CREATE INDEX IF NOT EXISTS idx_quotes_customer_id ON quotes(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotes_status ON quotes(status);
CREATE INDEX IF NOT EXISTS idx_quotes_valid_until ON quotes(valid_until);

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================
-- SCHEMA COMPLETE
-- ============================================
-- This schema includes:
-- ✓ Products table
-- ✓ Invoices table (with company, customer_phone, last_reminder_sent)
-- ✓ Users table
-- ✓ Customers table (without gender field)
-- ✓ Quotes table (NEW)
-- ✓ App Settings table
-- ✓ Performance indexes
-- ✓ Initial seed data
-- ============================================

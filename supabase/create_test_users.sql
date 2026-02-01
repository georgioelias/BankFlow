-- Create Test Users for BankFlow App
-- Run this in Supabase SQL Editor
-- These users will have real auth credentials you can log in with

-- Password for all test users: test123
-- The password hash below is for 'test123'

-- First, let's create the users in auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role,
  aud,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
VALUES 
  -- User 1: Georgio Elias
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '00000000-0000-0000-0000-000000000000',
    'georgio@test.com',
    crypt('test123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Georgio Elias"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  -- User 2: Sarah Johnson
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '00000000-0000-0000-0000-000000000000',
    'sarah@test.com',
    crypt('test123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Sarah Johnson"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  -- User 3: Mike Chen
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '00000000-0000-0000-0000-000000000000',
    'mike@test.com',
    crypt('test123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Mike Chen"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  )
ON CONFLICT (id) DO NOTHING;

-- Create identities for these users (required for login)
INSERT INTO auth.identities (
  id,
  user_id,
  provider_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
VALUES
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'georgio@test.com',
    '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "email": "georgio@test.com"}',
    'email',
    NOW(),
    NOW(),
    NOW()
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'sarah@test.com',
    '{"sub": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb", "email": "sarah@test.com"}',
    'email',
    NOW(),
    NOW(),
    NOW()
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'mike@test.com',
    '{"sub": "cccccccc-cccc-cccc-cccc-cccccccccccc", "email": "mike@test.com"}',
    'email',
    NOW(),
    NOW(),
    NOW()
  )
ON CONFLICT (id) DO NOTHING;

-- Now create the public.users profiles
-- First disable RLS temporarily
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;

-- Insert user profiles
INSERT INTO public.users (id, email, full_name, balance, phone, is_verified, created_at)
VALUES 
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'georgio@test.com', 'Georgio Elias', 25000.00, '+1234567890', true, NOW() - INTERVAL '30 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'sarah@test.com', 'Sarah Johnson', 18500.50, '+1234567891', true, NOW() - INTERVAL '20 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'mike@test.com', 'Mike Chen', 32000.00, '+1234567892', true, NOW() - INTERVAL '15 days')
ON CONFLICT (id) DO UPDATE SET 
  balance = EXCLUDED.balance,
  full_name = EXCLUDED.full_name;

-- Add cards for Georgio
INSERT INTO public.cards (id, user_id, card_type, card_number, card_holder_name, expiry_date, is_active, is_primary, daily_limit)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'visa', '**** **** **** 4532', 'GEORGIO ELIAS', '12/28', true, true, 10000.00),
  ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'mastercard', '**** **** **** 8721', 'GEORGIO ELIAS', '06/27', true, false, 5000.00)
ON CONFLICT (id) DO NOTHING;

-- Add cards for Sarah
INSERT INTO public.cards (id, user_id, card_type, card_number, card_holder_name, expiry_date, is_active, is_primary, daily_limit)
VALUES 
  ('33333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'visa', '**** **** **** 9876', 'SARAH JOHNSON', '03/27', true, true, 8000.00)
ON CONFLICT (id) DO NOTHING;

-- Add cards for Mike
INSERT INTO public.cards (id, user_id, card_type, card_number, card_holder_name, expiry_date, is_active, is_primary, daily_limit)
VALUES 
  ('44444444-4444-4444-4444-444444444444', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'mastercard', '**** **** **** 5555', 'MIKE CHEN', '09/26', true, true, 15000.00)
ON CONFLICT (id) DO NOTHING;

-- Add some transactions between users
INSERT INTO public.transactions (id, user_id, recipient_id, amount, type, status, description, category, created_at)
VALUES 
  -- Georgio's transactions
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 500.00, 'send', 'completed', 'Dinner split', 'Food', NOW() - INTERVAL '2 hours'),
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1200.00, 'receive', 'completed', 'Project payment', 'Income', NOW() - INTERVAL '1 day'),
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, 5000.00, 'deposit', 'completed', 'Salary deposit', 'Income', NOW() - INTERVAL '3 days'),
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, 89.99, 'payment', 'completed', 'Netflix subscription', 'Entertainment', NOW() - INTERVAL '5 days'),
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 250.00, 'send', 'completed', 'Concert tickets', 'Entertainment', NOW() - INTERVAL '7 days'),
  
  -- Sarah's transactions
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 300.00, 'send', 'completed', 'Birthday gift', 'Gifts', NOW() - INTERVAL '4 hours'),
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, 3500.00, 'deposit', 'completed', 'Freelance payment', 'Income', NOW() - INTERVAL '2 days'),
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, 150.00, 'payment', 'completed', 'Grocery shopping', 'Food', NOW() - INTERVAL '3 days'),
  
  -- Mike's transactions
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 800.00, 'send', 'completed', 'Rent share', 'Housing', NOW() - INTERVAL '1 day'),
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', NULL, 10000.00, 'deposit', 'completed', 'Bonus', 'Income', NOW() - INTERVAL '5 days'),
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 2000.00, 'receive', 'completed', 'Investment return', 'Income', NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;

-- Add notifications for Georgio
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at)
VALUES 
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Money Received', 'You received $1,200 from Mike Chen', 'transaction', false, NOW() - INTERVAL '1 day'),
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Transfer Successful', 'You sent $500 to Sarah Johnson', 'transaction', false, NOW() - INTERVAL '2 hours'),
  (gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Salary Deposited', 'Your salary of $5,000 has been deposited', 'success', true, NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- Re-enable RLS with permissive policies for testing
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies and create open ones for demo
DROP POLICY IF EXISTS "Allow all for demo" ON public.users;
DROP POLICY IF EXISTS "Allow all for demo" ON public.transactions;
DROP POLICY IF EXISTS "Allow all for demo" ON public.cards;
DROP POLICY IF EXISTS "Allow all for demo" ON public.notifications;

CREATE POLICY "Allow all for demo" ON public.users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON public.transactions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON public.cards FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON public.notifications FOR ALL USING (true) WITH CHECK (true);

-- Verify the data
SELECT 'Test Users Created:' as info;
SELECT email, full_name, balance FROM public.users WHERE id IN (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'cccccccc-cccc-cccc-cccc-cccccccccccc'
);
